
--
-- the order of loading scripts must be kept as below:
--

-- 1. we work with utf8
SET CHARACTER SET utf8;

-- 2. first load table definitions:
SOURCE ktm-dbschema.sql

-- 3. initialize tables to keep constraints satisfied:
SOURCE ktm-initdata.sql

-- 4. now load some automatics which are best kept on db level:
SOURCE ktm-trigger.sql

-- 5. finaly load dummy data
SOURCE loadata.sql

