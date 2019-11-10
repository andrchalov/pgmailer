--
-- pgmailer.sender_error()
--

-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION pgmailer.sender_error(
  a_outmsg_id bigint, a_error text
)
  RETURNS void
  LANGUAGE plpgsql
  SECURITY DEFINER
AS $function$
BEGIN
  UPDATE _pgmailer.outmsg
    SET errlog = array_append(errlog, date_trunc('minute', now())||' - '||a_error)
    WHERE id = a_outmsg_id
      AND state = 'locked';
  --
  IF NOT found THEN
    RAISE 'PGMAILER: cannot save error to outmsg #%', a_outmsg_id;
  END IF;
END;
$function$;
-------------------------------------------------------------------------------
