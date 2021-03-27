--
-- pgmailer.sender_take()
--

-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION pgmailer.sender_take()
  RETURNS json
  LANGUAGE plpgsql
  SECURITY DEFINER
AS $function$
DECLARE
  v_outmsg record;
  v_state text;
  v_sendattempts smallint;
BEGIN
  SELECT
      id, from_email, from_name, to_email, to_name, reply_email, reply_name,
      subject, body_text, body_html, sendattempts
    FROM _pgmailer.outmsg
    WHERE state = 'queued'
    ORDER BY priority DESC, mo ASC
    LIMIT 1
    FOR UPDATE SKIP LOCKED
    INTO v_outmsg;
  --
  IF found THEN
    UPDATE _pgmailer.outmsg
      SET locked = now()
      WHERE id = v_outmsg.id
      RETURNING state, sendattempts INTO STRICT v_state, v_sendattempts;

    IF v_state IS DISTINCT FROM 'locked' THEN
      RAISE 'PGMAILER: outmsg not locked, it is in % state', v_state;
    END IF;

    IF NOT v_sendattempts > v_outmsg.sendattempts THEN
      RAISE 'PGMAILER: outmsg sendattempts not increased';
    END IF;

    RETURN row_to_json(v_outmsg);
  ELSE
    -- actualize locked outmsg states
    UPDATE _pgmailer.outmsg SET id = id
      WHERE state = ANY ('{locked,waiting}');

    RETURN null;
  END IF;
END;
$function$;
-------------------------------------------------------------------------------
