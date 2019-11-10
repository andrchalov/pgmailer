--
-- pgmailer.outmsg
--

\ir before_action.sql
\ir after_action.sql

--------------------------------------------------------------------------------
-- TRIGGERS --------------------------------------------------------------------
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
CREATE TRIGGER before_action
  BEFORE INSERT OR UPDATE
  ON _pgmailer.outmsg
  FOR EACH ROW
  EXECUTE PROCEDURE pgmailer.outmsg_before_action();
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
CREATE TRIGGER after_action
  AFTER INSERT OR UPDATE
  ON _pgmailer.outmsg
  FOR EACH ROW
  EXECUTE PROCEDURE pgmailer.outmsg_after_action();
--------------------------------------------------------------------------------
