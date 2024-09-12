
-- --------------------------------------------------------------------
-- signalquelle triggers
-- --------------------------------------------------------------------

-- clean first

DROP FUNCTION IF EXISTS sq_getallkids;

DROP PROCEDURE IF EXISTS sq_loadraw;

DROP PROCEDURE IF EXISTS sq_diveidx;
DROP PROCEDURE IF EXISTS sq_calcindex;
DROP PROCEDURE IF EXISTS sq_setindex;

DROP TRIGGER IF EXISTS sq_bupdate;
DROP TRIGGER IF EXISTS sq_aupdate;
DROP TRIGGER IF EXISTS sq_binsert;
DROP TRIGGER IF EXISTS sq_ainsert;
DROP TRIGGER IF EXISTS sq_bdelete;
DROP TRIGGER IF EXISTS sq_adelete;

DROP TRIGGER IF EXISTS spf_ainsert;
DROP TRIGGER IF EXISTS spf_adelete;

DROP TRIGGER IF EXISTS tpf_ainsert;
DROP TRIGGER IF EXISTS tpf_adelete;

DROP TRIGGER IF EXISTS kpf_ainsert;
DROP TRIGGER IF EXISTS kpf_aupdate;
DROP TRIGGER IF EXISTS kpf_adelete;

DROP TRIGGER IF EXISTS sb_ainsert;
DROP TRIGGER IF EXISTS sb_aupdate;
DROP TRIGGER IF EXISTS sb_adelete;

DELIMITER //

SET GLOBAL log_bin_trust_function_creators = 1;

-- finds deep last node of the branch parent
CREATE FUNCTION sq_getallkids (parent INTEGER UNSIGNED)
RETURNS INTEGER UNSIGNED
NOT DETERMINISTIC
BEGIN

	DECLARE xcount INTEGER UNSIGNED;
	DECLARE xfirst INTEGER UNSIGNED;
	DECLARE fidx0 INTEGER UNSIGNED;
	DECLARE lidx0 INTEGER UNSIGNED DEFAULT NULL;
	DECLARE flevel SMALLINT;

	-- MyShit is very difficult with real subqueries and procedure CALL
	-- so we put resultset into temporary table and read it from there
	-- this one here MUST HAVE exact columns as the table signalquelle
	DROP TEMPORARY TABLE IF EXISTS sq_getallkids;
	CREATE TEMPORARY TABLE sq_getallkids(
		 uidx INTEGER UNSIGNED NOT NULL,
		 tidx0 INTEGER UNSIGNED NOT NULL DEFAULT 0,
		 tidx1 INTEGER UNSIGNED NOT NULL DEFAULT 0,
		 tidx2 INTEGER UNSIGNED NOT NULL DEFAULT 0,
		 tidx3 INTEGER UNSIGNED NOT NULL DEFAULT 0,
		 tlevel SMALLINT NOT NULL DEFAULT 0,
		 ptemp INTEGER UNSIGNED NOT NULL DEFAULT 0,
		 ntemp INTEGER UNSIGNED NOT NULL DEFAULT 0,
		 co_idx INTEGER UNSIGNED NOT NULL DEFAULT 0,
		 sq_idx INTEGER UNSIGNED NOT NULL DEFAULT 0,
		 sq_type SMALLINT UNSIGNED NULL,
		 sumwe INTEGER UNSIGNED NULL,
		 wesoll INTEGER UNSIGNED NULL,
		 netzid VARCHAR(16) NULL,
		 dataorigin SMALLINT UNSIGNED NULL,
		 strasse VARCHAR(64) NULL,
		 hausnr VARCHAR(8) NULL,
		 hausnrzus VARCHAR(8) NULL,
		 plz VARCHAR(8) NULL,
		 ort VARCHAR(64) NULL,
		 land SMALLINT UNSIGNED NULL,
		 region SMALLINT UNSIGNED NULL,
		 PRIMARY KEY(uidx)
	) ENGINE=Memory COMMENT='sq_getallkids() results';

	-- check for the kids
	SELECT count, tnext INTO xcount, xfirst FROM sqhelper WHERE sq_idx = parent;

	-- this is either kid or next node
	SELECT tidx0, tlevel INTO fidx0, flevel FROM signalquelle WHERE uidx = xfirst;

	-- has kids, dive into
	WHILE xcount > 0 DO
		SELECT uidx, tidx0 INTO parent, lidx0 FROM signalquelle WHERE sq_idx = parent ORDER BY tlevel DESC, tidx0 DESC, tidx1 DESC, tidx2 DESC, tidx3 DESC LIMIT 1;
		-- check for the kids
		SELECT count INTO xcount FROM sqhelper WHERE sq_idx = parent;
	END WHILE;

	-- if no kids or last node or both the lidx0 will stay NULL
	INSERT sq_getallkids SELECT * FROM signalquelle WHERE (tidx0 >= fidx0 AND tidx0 <= lidx0 AND tlevel >= flevel) ORDER BY tidx0, tidx1, tidx2, tidx3;

	SELECT count(*) INTO xcount FROM sq_getallkids;
	RETURN xcount;
END//


-- loads signalquelle data tree which MUST BE IN ITS SEQUENTIAL TREE-ORDER
-- the new tree nodes are always appended last, therefore all new branches
-- must have an open end. THE NODES CANNOT BE INSERTED IN-BETWEEEN HERE!
-- usefull for quick data restore from previously ordered tree backup.
CREATE PROCEDURE sq_loadraw (parent INTEGER UNSIGNED, OUT prev INTEGER UNSIGNED, OUT next INTEGER UNSIGNED, OUT idx0 INTEGER UNSIGNED, OUT lev INTEGER UNSIGNED)
procblock: BEGIN

	DECLARE xprev INTEGER UNSIGNED;
	DECLARE xpidx0 INTEGER UNSIGNED;
	DECLARE xnidx0 INTEGER UNSIGNED;

	-- pickup the last tree node pointed by the tprev of sentinel
	SELECT tprev INTO xprev FROM sqhelper WHERE sq_idx = 0;

	-- no nodes yet. inserts the first data node and seeds idx0
	IF xprev = 0 THEN
		SET idx0 = 1; SET lev = 1;
		SET prev = 0; SET next = 0;
		LEAVE procblock;
	END IF;

	-- pickup the tidx0 of the last node
	SELECT tidx0 INTO xpidx0
		FROM signalquelle WHERE uidx = xprev;

	-- appends node at the end
	SET idx0 = xpidx0 + 1024;
	SET prev = xprev; SET next = 0;

	-- pickup the tlevel of the parent node
	SELECT tlevel INTO lev
		FROM signalquelle WHERE uidx = parent;

	-- set the node level
	SET lev = lev + 1;

END procblock//


-- calculations for neighbour index columns A and B
-- previous index and result goes into idx, next index into nidx
CREATE PROCEDURE sq_diveidx (INOUT idxA INTEGER UNSIGNED, INOUT idxB INTEGER UNSIGNED, diffA INTEGER UNSIGNED, nidxB INTEGER UNSIGNED)
procblock: BEGIN

	DECLARE smax INTEGER UNSIGNED;
	DECLARE rest INTEGER UNSIGNED;
	DECLARE rangeB INTEGER UNSIGNED;
	DECLARE correction INTEGER UNSIGNED;

	SET smax = POW(2, 32) - 1;

	SET idxA = idxA + (diffA DIV 2);
	SET rest = MOD(diffA, 2);

	-- find the index balance acording to prev and next ranges

	-- available slots in prev index idxB
	SET rangeB = smax - idxB;

	-- the balance is on the side of the next index nidxB
	IF nidxB > rangeB THEN
		SET correction = (nidxB - rangeB) DIV 2;
		-- adjust balance for the slots in next direction
		IF rest = 1 THEN
			SET idxA = idxA + 1;
			SET idxB = correction;
		ELSE
			SET idxB = (smax DIV 2) + correction;
		END IF;
	-- the balance is on the side of the prev index idxB
	ELSE
		SET correction = (rangeB - nidxB) DIV 2;
		-- adjust balance for the slots in prev direction
		IF rest = 1 THEN
			SET idxB = smax - correction;
		ELSE
			SET idxB = (smax DIV 2) - correction;
		END IF;
	END IF;

END procblock//


-- calculates new middle index of given previous idx and next nidx indexes
CREATE PROCEDURE sq_calcindex (INOUT idx0 INTEGER UNSIGNED, INOUT idx1 INTEGER UNSIGNED, INOUT idx2 INTEGER UNSIGNED, INOUT idx3 INTEGER UNSIGNED, nidx0 INTEGER UNSIGNED, nidx1 INTEGER UNSIGNED, nidx2 INTEGER UNSIGNED, nidx3 INTEGER UNSIGNED, grow INTEGER UNSIGNED)
procblock: BEGIN

	DECLARE diff INTEGER UNSIGNED;
	DECLARE growmark INTEGER UNSIGNED;

	SET diff = nidx0 - idx0;
	IF diff = 0 THEN
		SET diff = nidx1 - idx1;
		IF diff = 0 THEN
			SET diff = nidx2 - idx2;
			IF diff = 0 THEN
				SET diff = nidx3 - idx3;
				IF diff = 1 THEN
					-- tree out of range, raise an #1442 error
					UPDATE signalquelle SET uidx=0 WHERE uidx=0;
					LEAVE procblock;
				END IF;
				SET idx3 = idx3 + (diff DIV 2);
				LEAVE procblock;
			END IF;
			CALL sq_diveidx (idx2, idx3, diff, nidx3);
			LEAVE procblock;
		END IF;
		CALL sq_diveidx (idx1, idx2, diff, nidx2);
		SET idx3 = 0;
		LEAVE procblock;
	END IF;

	IF diff > 1 THEN
		-- grow idx0 steps backwards of decrement grow until step difference between
		-- idx0 and nidx0 reached. then grow again in steps of decrement 1 until
		-- we start to use idx1. with this we gain 2 x grow entries of subsequential
		-- insert after the same prev node if idx0 resolution was set grow x grow.
		SET growmark = idx0 + grow;
		IF nidx0 > growmark THEN
			SET idx0 = nidx0 - grow;
		ELSE
			SET idx0 = nidx0 - 1;
		END IF;
		SET idx1 = 0;
		LEAVE procblock;
	END IF;

	-- this is called only for nidx0 - idx0 diff 1
	CALL sq_diveidx (idx0, idx1, diff, nidx1);
	SET idx2 = 0; SET idx3 = 0;

END procblock//


-- inserts node at the exact position within the tree given by prev and parent
CREATE PROCEDURE sq_setindex (parent INTEGER UNSIGNED, prev INTEGER UNSIGNED, OUT next INTEGER UNSIGNED, OUT idx0 INTEGER UNSIGNED, OUT idx1 INTEGER UNSIGNED, OUT idx2 INTEGER UNSIGNED, OUT idx3 INTEGER UNSIGNED, OUT lev INTEGER UNSIGNED)
procblock: BEGIN

	DECLARE xnidx0 INTEGER UNSIGNED;
	DECLARE xnidx1 INTEGER UNSIGNED;
	DECLARE xnidx2 INTEGER UNSIGNED;
	DECLARE xnidx3 INTEGER UNSIGNED;

	DECLARE idx0resolution INTEGER UNSIGNED DEFAULT 1024;
	DECLARE idx0grow INTEGER UNSIGNED DEFAULT 32;

	SET idx0 = 0; SET idx1 = 0; SET idx2 = 0; SET idx3 = 0;

	-- pickup the tlevel of the parent node
	SELECT tlevel INTO lev
		FROM signalquelle WHERE uidx = parent;

	-- set the node level
	SET lev = lev + 1;

	-- pickup the next node pointed by the to-be previous node
	SELECT tnext INTO next FROM sqhelper WHERE sq_idx = prev;

	-- insert after last node (append)
	IF next = 0 THEN
		-- get idx0 of the to-be prev node and increase it
		SELECT tidx0 INTO idx0 FROM signalquelle WHERE uidx = prev;
		-- doubt that POW(2,32) check is necesary for this app :)
		SET idx0 = idx0 + idx0resolution;
		LEAVE procblock;
	END IF;

	IF prev != 0 THEN
		-- get indexes of the to-be prev node
		SELECT tidx0, tidx1, tidx2, tidx3
			INTO idx0, idx1, idx2, idx3
			FROM signalquelle WHERE uidx = prev;
	END IF;

	-- get indexes of the to-be next node
	SELECT tidx0, tidx1, tidx2, tidx3
		INTO xnidx0, xnidx1, xnidx2, xnidx3
		FROM signalquelle WHERE uidx = next;

	-- calculate new index which will be set into idx params
	CALL sq_calcindex(idx0, idx1, idx2, idx3, xnidx0, xnidx1, xnidx2, xnidx3, idx0grow);

END procblock//


CREATE TRIGGER sq_binsert BEFORE INSERT ON signalquelle
FOR EACH ROW
BEGIN
	-- ptemp and ntemp are temporary index pointers and are used
	-- only by the trigger to complete new insert transaction.
	-- their values in signalquelle does not have any meaning.
	IF NEW.tlevel = -1 THEN
		-- appends new nodes at the end of the existing branches
		-- without providing prev pointer. used for data restore.
		-- must be indicated by setting tlevel -1, otherwise error
		CALL sq_loadraw(NEW.sq_idx, NEW.ptemp, NEW.ntemp, NEW.tidx0, NEW.tlevel);
	ELSE
		-- insert operation for the tree nodes which calculates tree-order tidx
		-- prev pointer must be provided to locate insert position of new node
		CALL sq_setindex(NEW.sq_idx, NEW.ptemp, NEW.ntemp, NEW.tidx0, NEW.tidx1, NEW.tidx2, NEW.tidx3, NEW.tlevel);
	END IF;
END//


CREATE TRIGGER sq_ainsert AFTER INSERT ON signalquelle
FOR EACH ROW
BEGIN
	-- new signalquelle helper row
	INSERT INTO sqhelper (sq_idx, tprev, tnext, count) VALUES
		(NEW.uidx, NEW.ptemp, NEW.ntemp, 0);
	-- update children counter of the parent
	UPDATE sqhelper SET count = count + 1 WHERE sq_idx = NEW.sq_idx;
	-- update neighbours pointers of the new neighbours
	UPDATE sqhelper SET tnext = NEW.uidx WHERE sq_idx = NEW.ptemp;
	UPDATE sqhelper SET tprev = NEW.uidx WHERE sq_idx = NEW.ntemp;

-- Populate sqsearch helper after transaction on signalquelle
	INSERT INTO sqsearch (sq_idx, sq_strasse, sq_hausnr, sq_hausnrzus, sq_plz, sq_ort, sq_land, sq_region)
		VALUES (NEW.uidx, NEW.strasse, NEW.hausnr, NEW.hausnrzus, NEW.plz, NEW.ort, NEW.land, NEW.region);

-- contactoffice refcounter:
	IF NEW.co_idx <> 0 THEN
		UPDATE contactoffice SET refcount = refcount + 1 WHERE uidx = NEW.co_idx;
	END IF;
END//

-- Here we need to recalculate indexes for the node and its kids

--CREATE TRIGGER sq_bupdate BEFORE UPDATE ON signalquelle
--FOR EACH ROW
--BEGIN
--   IF OLD.sq_idx <> NEW.sq_idx THEN
--   END IF;
--END//

-- Populate sqsearch helper after transaction on signalquelle

CREATE TRIGGER sq_aupdate AFTER UPDATE ON signalquelle
FOR EACH ROW
BEGIN
	UPDATE sqsearch SET sq_strasse = NEW.strasse, sq_hausnr = NEW.hausnr, sq_hausnrzus = NEW.hausnrzus, sq_plz = NEW.plz, sq_ort = NEW.ort, sq_land = NEW.land, sq_region = NEW.region
		WHERE sq_idx = NEW.uidx;

-- contactoffice refcounter:
	-- no attachment yet
	IF OLD.co_idx = 0 THEN
		-- INCREMENT NEW, attachment
		IF NEW.co_idx <> 0 THEN
			UPDATE contactoffice SET refcount = refcount + 1 WHERE uidx = NEW.co_idx;
		END IF;
	-- already attached
	ELSE
		-- DECREMENT OLD, dettachment
		IF NEW.co_idx = 0 THEN
			UPDATE contactoffice SET refcount = refcount - 1 WHERE uidx = OLD.co_idx;
		-- DECREMENT OLD, dettachment
		-- INCREMENT NEW, attachment
		ELSEIF OLD.co_idx <> NEW.co_idx THEN
			UPDATE contactoffice SET refcount = refcount - 1 WHERE uidx = OLD.co_idx;
			UPDATE contactoffice SET refcount = refcount + 1 WHERE uidx = NEW.co_idx;
		END IF;
	END IF;
END//

--

CREATE TRIGGER sq_bdelete BEFORE DELETE ON signalquelle
FOR EACH ROW
BEGIN
	DECLARE prev INTEGER UNSIGNED;
	DECLARE next INTEGER UNSIGNED;
	-- only update prev and next pointers
	-- the node in sqhelper will be automaticaly deleted (CASCADE)
	SELECT tprev, tnext INTO prev, next FROM sqhelper WHERE sq_idx = OLD.uidx;

	-- update children counter of the parent
	UPDATE sqhelper SET count = count - 1 WHERE sq_idx = OLD.sq_idx;
	-- update neighbours pointers of the old neighbours
	UPDATE sqhelper SET tnext = next WHERE sq_idx = prev;
	UPDATE sqhelper SET tprev = prev WHERE sq_idx = next;
END//

CREATE TRIGGER sq_adelete AFTER DELETE ON signalquelle
FOR EACH ROW
BEGIN
	-- delete sqsearch entry
	DELETE FROM sqsearch WHERE sq_idx = OLD.uidx;

-- contactoffice refcounter:
	IF OLD.co_idx <> 0 THEN
		UPDATE contactoffice SET refcount = refcount - 1 WHERE uidx = OLD.co_idx;
	END IF;
END//


-- ----------------------------------------------------------------------------
-- satprogfreq related refcounts

CREATE TRIGGER spf_ainsert AFTER INSERT ON satprogfreq 
FOR EACH ROW
BEGIN
	UPDATE signalbezug SET refcount = refcount + 1 WHERE uidx = NEW.sb_idx;
	UPDATE programm SET refcount = refcount + 1 WHERE uidx = NEW.pg_idx;
END//

CREATE TRIGGER spf_adelete AFTER DELETE ON satprogfreq 
FOR EACH ROW
BEGIN
	UPDATE signalbezug SET refcount = refcount - 1 WHERE uidx = OLD.sb_idx;
	UPDATE programm SET refcount = refcount - 1 WHERE uidx = OLD.pg_idx;
END//

-- ----------------------------------------------------------------------------

-- ----------------------------------------------------------------------------
-- terrprogfreq related refcounts

CREATE TRIGGER tpf_ainsert AFTER INSERT ON terrprogfreq 
FOR EACH ROW
BEGIN
	UPDATE signalbezug SET refcount = refcount + 1 WHERE uidx = NEW.sb_idx;
	UPDATE programm SET refcount = refcount + 1 WHERE uidx = NEW.pg_idx;
END//

CREATE TRIGGER tpf_adelete AFTER DELETE ON terrprogfreq 
FOR EACH ROW
BEGIN
	UPDATE signalbezug SET refcount = refcount - 1 WHERE uidx = OLD.sb_idx;
	UPDATE programm SET refcount = refcount - 1 WHERE uidx = OLD.pg_idx;
END//

-- ----------------------------------------------------------------------------

-- ----------------------------------------------------------------------------
-- kabelprogfreq related refcounts

-- update is relevant only for kanalfreq
CREATE TRIGGER kpf_aupdate AFTER UPDATE ON kabelprogfreq 
FOR EACH ROW
BEGIN
	-- no attachment yet
	IF OLD.kf_idx = 0 THEN
		-- INCREMENT NEW, attachment
		IF NEW.kf_idx <> 0 THEN
			UPDATE kanalfreq SET refcount = refcount + 1 WHERE uidx = NEW.kf_idx;
		END IF;
	-- already attached
	ELSE
		-- DECREMENT OLD, dettachment
		IF NEW.kf_idx = 0 THEN
			UPDATE kanalfreq SET refcount = refcount - 1 WHERE uidx = OLD.kf_idx;
		-- DECREMENT OLD, dettachment
		-- INCREMENT NEW, attachment
		ELSEIF OLD.kf_idx <> NEW.kf_idx THEN
			UPDATE kanalfreq SET refcount = refcount - 1 WHERE uidx = OLD.kf_idx;
			UPDATE kanalfreq SET refcount = refcount + 1 WHERE uidx = NEW.kf_idx;
		END IF;
	END IF;
END//

CREATE TRIGGER kpf_ainsert AFTER INSERT ON kabelprogfreq 
FOR EACH ROW
BEGIN
	-- attach record to sbprovider
	IF NEW.sb_idx = 0 THEN
		UPDATE sbprovider SET refcount = refcount + 1 WHERE uidx = NEW.sbp_idx;
	-- attach record to signalbezug
	ELSE
		UPDATE signalbezug SET refcount = refcount + 1 WHERE uidx = NEW.sb_idx;
	END IF;
	UPDATE programm SET refcount = refcount + 1 WHERE uidx = NEW.pg_idx;
END//

CREATE TRIGGER kpf_adelete AFTER DELETE ON kabelprogfreq 
FOR EACH ROW
BEGIN
	-- dettach record from sbprovider
	IF OLD.sb_idx = 0 THEN
		UPDATE sbprovider SET refcount = refcount - 1 WHERE uidx = OLD.sbp_idx;
	-- dettach record from signalbezug
	ELSE
		UPDATE signalbezug SET refcount = refcount - 1 WHERE uidx = OLD.sb_idx;
	END IF;
	UPDATE programm SET refcount = refcount - 1 WHERE uidx = OLD.pg_idx;
END//

-- ----------------------------------------------------------------------------

-- ----------------------------------------------------------------------------
-- signalbezug related refcounts

CREATE TRIGGER sb_aupdate AFTER UPDATE ON signalbezug
FOR EACH ROW
BEGIN
	-- no attachment yet
	IF OLD.sbp_idx = 0 THEN
		-- INCREMENT NEW, attachment
		IF NEW.sbp_idx <> 0 THEN
			UPDATE sbprovider SET refcount = refcount + 1 WHERE uidx = NEW.sbp_idx;
		END IF;
	-- already attached
	ELSE
		-- DECREMENT OLD, dettachment
		IF NEW.sbp_idx = 0 THEN
			UPDATE sbprovider SET refcount = refcount - 1 WHERE uidx = OLD.sbp_idx;
		-- DECREMENT OLD, dettachment
		-- INCREMENT NEW, attachment
		ELSEIF OLD.sbp_idx <> NEW.sbp_idx THEN
			UPDATE sbprovider SET refcount = refcount - 1 WHERE uidx = OLD.sbp_idx;
			UPDATE sbprovider SET refcount = refcount + 1 WHERE uidx = NEW.sbp_idx;
		END IF;
	END IF;
END//

CREATE TRIGGER sb_ainsert AFTER INSERT ON signalbezug
FOR EACH ROW
BEGIN
	IF NEW.sbp_idx <> 0 THEN
		UPDATE sbprovider SET refcount = refcount + 1 WHERE uidx = NEW.sbp_idx;
	END IF;
END//

CREATE TRIGGER sb_adelete AFTER DELETE ON signalbezug
FOR EACH ROW
BEGIN
	IF OLD.sbp_idx <> 0 THEN
		UPDATE sbprovider SET refcount = refcount - 1 WHERE uidx = OLD.sbp_idx;
	END IF;
END//

-- ----------------------------------------------------------------------------

DELIMITER ;

