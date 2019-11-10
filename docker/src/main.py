#!/usr/bin/python3
# -*- coding: utf-8 -*-

import logging
import psycopg2
import select
import smtplib
import os
import sys
import json
import time
from email.message import EmailMessage
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from email.headerregistry import Address
from email.utils import make_msgid
from email.utils import format_datetime
from email.utils import localtime
from utils.config import get_config

CONFIG_TEMPLATE = (
  ("SMTP_HOST", None, True),
  ("SMTP_PORT", 25, False),
  ("SMTP_LOGIN", None, True),
  ("SMTP_PASSWORD", None, True),
  ("LOGLEVEL", "INFO", False)
)

logger = logging.getLogger("main")
config = get_config(CONFIG_TEMPLATE)
logging.basicConfig(stream=sys.stdout, level=config["LOGLEVEL"])

SMTP_HOST = config["SMTP_HOST"]
SMTP_PORT = config["SMTP_PORT"]
SMTP_LOGIN = config["SMTP_LOGIN"]
SMTP_PASSWORD = config["SMTP_PASSWORD"]

conn = psycopg2.connect("")
conn.autocommit = True

curs = conn.cursor()

curs.execute('LISTEN "pgmailer:queued_outmsg"')
smtpconn = None

while 1:
  logging.debug(u'Fetching new outmsg')
  curs.execute('SELECT * FROM pgmailer.sender_take()')
  res = curs.fetchone()
  outmsg = res[0]

  if outmsg:
    outmsg_id = outmsg['id']

    logging.debug(u'Have new outmsg #%s', outmsg_id)

    try:
      if not smtpconn:
        logging.debug(u'Connecting to stmp')
        smtpconn = smtplib.SMTP(SMTP_HOST, SMTP_PORT)
        smtpconn.starttls()
        smtpconn.login(SMTP_LOGIN, SMTP_PASSWORD)

      msg = MIMEMultipart('alternative', _charset='UTF-8')

      msg['Subject'] = outmsg['subject']

      from_addr = Address(display_name=outmsg['from_name'], addr_spec=outmsg['from_email'])
      msg['From'] = from_addr.__str__()

      to_addr = Address(display_name=outmsg['to_name'], addr_spec=outmsg['to_email'])
      msg['To'] = to_addr.__str__()

      if outmsg['reply_email']:
        reply_addr = Address(display_name=(outmsg['reply_name'] or ''), addr_spec=outmsg['reply_email'])
        msg['Reply-To'] = reply_addr.__str__()
        logging.debug(u'Reply-To %s', msg['Reply-To'])

      if outmsg['body_text']:
        msg.attach(MIMEText(outmsg['body_text'], 'plain'))

      if outmsg['body_html']:
        msg.attach(MIMEText(outmsg['body_html'], 'html'))

      # msg.add_header('Message-Id', make_msgid(domain=from_addr.domain))
      msg.add_header('Date', format_datetime(localtime(), True))

      logging.debug(u'Sending email')

      smtpconn.send_message(msg)

      curs.execute('SELECT pgmailer.sender_complete(%s)', (outmsg_id,))

      logging.debug(u'Outmsg #%s sended', outmsg_id)

    except Exception:
      logging.error(u'%s', sys.exc_info()[1].args[0])
      curs.execute('SELECT pgmailer.sender_error(%s, %s::text)', (outmsg_id, sys.exc_info()[1].args[0]))
      smtpconn = None
      time.sleep(10)

    continue

  if smtpconn:
    smtpconn.quit()
    smtpconn = None

  wait = True
  while wait:
    if select.select([conn],[],[],30) != ([],[],[]):
      while conn.notifies:
        notify = conn.notifies.pop(0)
        logging.debug(u'Getting notification %s', notify.channel)

      wait = False
