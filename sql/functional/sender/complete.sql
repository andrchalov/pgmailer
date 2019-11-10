--
-- pgmailer.sender_complete()
--

-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION pgmailer.sender_complete(a_outmsg_id bigint)
  RETURNS void
  LANGUAGE plpgsql
  SECURITY DEFINER
AS $function$
DECLARE
  v_state text;
BEGIN
  UPDATE pgmailer.outmsg
    SET sended = now()
    WHERE id = a_outmsg_id
      AND state = 'locked'
    RETURNING state INTO v_state;
  --
  IF NOT found THEN
    RAISE 'PGMAILER: locked outmsg #% not found', a_outmsg_id;
  END IF;

  IF v_state IS DISTINCT FROM 'sended' THEN
    RAISE 'PGMAILER: outmsg should be in sended state, but it is in % state',
      v_state;
  END IF;
END;
$function$;
-------------------------------------------------------------------------------
