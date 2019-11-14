--
-- pgmailer
--

--------------------------------------------------------------------------------
CREATE SCHEMA pgmailer AUTHORIZATION :"schema_owner";
GRANT USAGE ON SCHEMA pgmailer TO :"pgmailer_user";
--------------------------------------------------------------------------------

\ir outmsg/__deploy.sql

SET SESSION AUTHORIZATION :"schema_owner";

\ir sender/complete.sql
\ir sender/error.sql
\ir sender/take.sql

RESET SESSION AUTHORIZATION;
