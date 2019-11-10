--
-- pgmailer.outmsg_after_action()
--

-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION pgmailer.outmsg_after_action()
  RETURNS trigger
  LANGUAGE plpgsql
AS $function$
BEGIN
  IF TG_OP = 'INSERT' THEN
    IF NEW.state = 'queued' THEN
      PERFORM pg_notify('pgmailer:queued_outmsg', NEW.id::text);
    END IF;
  END IF;

  RETURN NEW;
END;
$function$;
-------------------------------------------------------------------------------
