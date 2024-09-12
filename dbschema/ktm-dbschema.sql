
DROP DATABASE ktmanager;
CREATE DATABASE ktmanager DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci;

DROP USER 'ktmanager'@localhost;
CREATE USER 'ktmanager'@localhost IDENTIFIED BY 'ktmanager';
GRANT ALL PRIVILEGES ON ktmanager . * TO 'ktmanager'@localhost;

USE ktmanager;


-- KANAL FREQUENZEN -----------------------------------------------------------

CREATE TABLE kanalfreq (
  uidx INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
  kanal VARCHAR(8) NULL,
  freq1 DECIMAL(10,4) NULL,
  freq2 DECIMAL(10,4) NULL,
  middfreq DECIMAL(10,4) NULL,
  bildtraeger DECIMAL(10,4) NULL,
  isradio BOOL DEFAULT FALSE,
  refcount INTEGER UNSIGNED NOT NULL DEFAULT 0,
  PRIMARY KEY(uidx),
  INDEX kf_kanal_idx(kanal),
  INDEX kf_isr_kanal_idx(isradio, kanal)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE utf8_unicode_ci;

-- PROGRAMM -------------------------------------------------------------------

CREATE TABLE programm (
  uidx INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
  pg_type SMALLINT UNSIGNED NULL,
  name VARCHAR(64) NULL,
  genre VARCHAR(64) NULL,
  land VARCHAR(128) NULL,
  sprache VARCHAR(128) NULL,
  teletext BOOL NULL DEFAULT FALSE,
  surround BOOL NULL DEFAULT FALSE,
  stereo BOOL NULL DEFAULT TRUE,
  hdtv BOOL NULL DEFAULT FALSE,
  dolbydig BOOL NULL DEFAULT FALSE,
  issched BOOL DEFAULT FALSE,
  schedfrom TIME NULL DEFAULT '00:00:00',
  schedto TIME NULL DEFAULT '00:00:00',
  anmerkungen TEXT NULL,
  betreiber VARCHAR(64) NULL,
  vertragsdaten VARCHAR(128) NULL DEFAULT 'keine Angabe',
  www VARCHAR(256) NULL,
  refcount INTEGER UNSIGNED NOT NULL DEFAULT 0,
  PRIMARY KEY(uidx),
  INDEX pg_pg_type(pg_type),
  INDEX pg_name(name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE utf8_unicode_ci;

CREATE TABLE bouquetprogramm (
  pgbq_idx INTEGER UNSIGNED NOT NULL,
  pg_idx INTEGER UNSIGNED NOT NULL,
  INDEX pgbq_pgbq_idx(pgbq_idx),
  INDEX bqpg_pg_idx(pg_idx),
  FOREIGN KEY(pg_idx)
    REFERENCES programm(uidx)
      ON DELETE CASCADE
      ON UPDATE NO ACTION,
  FOREIGN KEY(pgbq_idx)
    REFERENCES programm(uidx)
      ON DELETE CASCADE
      ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE utf8_unicode_ci;


-- SIGNALQUELLE ---------------------------------------------------------------

CREATE TABLE contactoffice (
  uidx INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
  firma VARCHAR(64) NULL,
  kontakt VARCHAR(64) NULL,
  telefon VARCHAR(32) NULL,
  fax VARCHAR(32) NULL,
  email VARCHAR(64) NULL,
  strasse VARCHAR(64) NULL,
  hausnr VARCHAR(8) NULL,
  hausnrzus VARCHAR(8) NULL,
  plz VARCHAR(8) NULL,
  ort VARCHAR(64) NULL,
  refcount INTEGER UNSIGNED NOT NULL DEFAULT 0,
  PRIMARY KEY(uidx)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE utf8_unicode_ci;

CREATE TABLE signalquelle (
  uidx INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
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
  PRIMARY KEY(uidx),
  INDEX sq_co_idx(co_idx),
  INDEX sq_sq_idx(sq_idx),
  INDEX sq_tree(tidx0, tidx1, tidx2, tidx3),
  INDEX sq_treelev(tlevel, tidx0, tidx1, tidx2, tidx3),
  FOREIGN KEY(sq_idx)
    REFERENCES signalquelle(uidx)
      ON DELETE CASCADE
      ON UPDATE NO ACTION,
  FOREIGN KEY(co_idx)
    REFERENCES contactoffice(uidx)
      ON DELETE NO ACTION
      ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE utf8_unicode_ci;

CREATE TABLE sqhelper (
  sq_idx INTEGER UNSIGNED NOT NULL,
  tprev INTEGER UNSIGNED NOT NULL DEFAULT 0,
  tnext INTEGER UNSIGNED NOT NULL DEFAULT 0,
  count INTEGER UNSIGNED NOT NULL DEFAULT 0,
  INDEX sqh_sq_idx(sq_idx),
  FOREIGN KEY(sq_idx)
    REFERENCES signalquelle(uidx)
      ON DELETE CASCADE
      ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE utf8_unicode_ci;

CREATE TABLE sqsearch (
  sq_idx INTEGER UNSIGNED NOT NULL,
  sq_strasse VARCHAR(64) NULL,
  sq_hausnr VARCHAR(8) NULL,
  sq_hausnrzus VARCHAR(8) NULL,
  sq_plz VARCHAR(8) NULL,
  sq_ort VARCHAR(64) NULL,
  sq_land SMALLINT UNSIGNED NULL,
  sq_region SMALLINT UNSIGNED NULL,
  PRIMARY KEY(sq_idx)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE utf8_unicode_ci;


-- SIGNALBEZUG ----------------------------------------------------------------

CREATE TABLE sbprovider (
  uidx INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
  name VARCHAR(256) NULL,
  firma VARCHAR(256) NULL,
  vertrag VARCHAR(256) NULL,
  kontakt1 VARCHAR(256) NULL,
  kontakt2 VARCHAR(256) NULL,
  land VARCHAR(128) NULL,
  email VARCHAR(64) NULL,
  www VARCHAR(256) NULL,
  iskabprov BOOL NULL,
  refcount INTEGER UNSIGNED NOT NULL DEFAULT 0,
  PRIMARY KEY(uidx),
  INDEX spb_iskabprov_idx(iskabprov)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE utf8_unicode_ci;

CREATE TABLE signalbezug (
  uidx INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
  sbp_idx INTEGER UNSIGNED NOT NULL DEFAULT 0,
  sb_type SMALLINT UNSIGNED NULL,
  kennung1 VARCHAR(128) NULL,
  kennung2 VARCHAR(128) NULL,
  sat_pos DECIMAL(5,2) NULL,
  sat_eirp DECIMAL(5,2) NULL,
  sat_beam VARCHAR(16) NULL,
  sat_band VARCHAR(64) NULL,
  sat_codx VARCHAR(4) NULL,
  up_strasse VARCHAR(64) NULL,
  up_hausnr VARCHAR(8) NULL,
  up_hausnrzus VARCHAR(8) NULL,
  up_plz VARCHAR(8) NULL,
  up_ort VARCHAR(64) NULL,
  up_issbprovkt BOOL NULL DEFAULT FALSE,
  refcount INTEGER UNSIGNED NOT NULL DEFAULT 0,
  PRIMARY KEY(uidx),
  INDEX sb_sbp_idx(sbp_idx),
  FOREIGN KEY(sbp_idx)
    REFERENCES sbprovider(uidx)
      ON DELETE NO ACTION
      ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE utf8_unicode_ci;

CREATE TABLE satprogfreq (
  uidx INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
  pg_idx INTEGER UNSIGNED NOT NULL DEFAULT 0,
  sb_idx INTEGER UNSIGNED NOT NULL DEFAULT 0,
  freq DECIMAL(10,4) NULL,
  zwfreq DECIMAL(10,4) NULL,
  polar VARCHAR(2) NULL,
  symbol VARCHAR(16) NULL,
  transp SMALLINT UNSIGNED NULL,
  spot VARCHAR(16) NULL,
  sig_type SMALLINT UNSIGNED NULL,
  bc_type SMALLINT UNSIGNED NULL,
  iscryp BOOL DEFAULT FALSE,
  PRIMARY KEY(uidx),
  INDEX spf_pg_idx(pg_idx),
  INDEX spf_sb_idx(sb_idx),
  FOREIGN KEY(pg_idx)
    REFERENCES programm(uidx)
      ON DELETE NO ACTION
      ON UPDATE NO ACTION,
  FOREIGN KEY(sb_idx)
    REFERENCES signalbezug(uidx)
      ON DELETE NO ACTION
      ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE utf8_unicode_ci;

CREATE TABLE kabelprogfreq (
  uidx INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
  pg_idx INTEGER UNSIGNED NOT NULL DEFAULT 0,
  sb_idx INTEGER UNSIGNED NOT NULL DEFAULT 0,
  sbp_idx INTEGER UNSIGNED NOT NULL DEFAULT 0,
  kf_idx INTEGER UNSIGNED NOT NULL DEFAULT 0,
  sig_type SMALLINT UNSIGNED NULL,
  bc_type SMALLINT UNSIGNED NULL,
  iscryp BOOL DEFAULT FALSE,
  PRIMARY KEY(uidx),
  INDEX kpf_pg_idx(pg_idx),
  INDEX kpf_sb_idx(sb_idx),
  INDEX kpf_sbp_idx(sbp_idx),
  INDEX kpf_kf_idx(kf_idx),
  FOREIGN KEY(pg_idx)
    REFERENCES programm(uidx)
      ON DELETE NO ACTION
      ON UPDATE NO ACTION,
  FOREIGN KEY(sb_idx)
    REFERENCES signalbezug(uidx)
      ON DELETE NO ACTION
      ON UPDATE NO ACTION,
  FOREIGN KEY(sbp_idx)
    REFERENCES sbprovider(uidx)
      ON DELETE NO ACTION
      ON UPDATE NO ACTION,
  FOREIGN KEY(kf_idx)
    REFERENCES kanalfreq(uidx)
      ON DELETE NO ACTION
      ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE utf8_unicode_ci;

CREATE TABLE terrprogfreq (
  uidx INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
  pg_idx INTEGER UNSIGNED NOT NULL DEFAULT 0,
  sb_idx INTEGER UNSIGNED NOT NULL DEFAULT 0,
  freq DECIMAL(10,4) NULL,
  polar VARCHAR(2) NULL,
  fec VARCHAR(8) NULL,
  fft VARCHAR(8) NULL,
  guard VARCHAR(8) NULL,
  mod_type SMALLINT UNSIGNED NULL,
  sig_type SMALLINT UNSIGNED NULL,
  bc_type SMALLINT UNSIGNED NULL,
  iscryp BOOL DEFAULT FALSE,
  PRIMARY KEY(uidx),
  INDEX tpf_pg_idx(pg_idx),
  INDEX tpf_sb_idx(sb_idx),
  FOREIGN KEY(pg_idx)
    REFERENCES programm(uidx)
      ON DELETE NO ACTION
      ON UPDATE NO ACTION,
  FOREIGN KEY(sb_idx)
    REFERENCES signalbezug(uidx)
      ON DELETE NO ACTION
      ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE utf8_unicode_ci;


-- KANALTABELLE ---------------------------------------------------------------

CREATE TABLE kanaltabelle (
  uidx INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
  kf_idx INTEGER UNSIGNED NOT NULL DEFAULT 1,
  pg_idx INTEGER UNSIGNED NOT NULL,
  -- these are required for quick delete
  sq_idx INTEGER UNSIGNED NOT NULL,
  sb_idx INTEGER UNSIGNED NOT NULL,
  -- -------------------------------------------------------
  inactive BOOL DEFAULT FALSE,
  PRIMARY KEY(uidx),
  INDEX kt_kf_idx(kf_idx),
  INDEX kt_pg_idx(pg_idx),
  INDEX kt_sb_idx(sb_idx),
  INDEX kt_sq_idx(sq_idx),
  INDEX kt_sbpg_idx(sb_idx, pg_idx),
  INDEX kt_sqsb_idx(sq_idx, sb_idx),
  FOREIGN KEY(kf_idx)
    REFERENCES kanalfreq(uidx)
      ON DELETE NO ACTION
      ON UPDATE NO ACTION,
  FOREIGN KEY(sq_idx)
    REFERENCES signalbezug(uidx)
      ON DELETE CASCADE
      ON UPDATE NO ACTION,
  FOREIGN KEY(sb_idx)
    REFERENCES signalbezug(uidx)
      ON DELETE CASCADE
      ON UPDATE NO ACTION,
  FOREIGN KEY(pg_idx)
    REFERENCES programm(uidx)
      ON DELETE CASCADE
      ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE utf8_unicode_ci;

CREATE TABLE signalquellenfilter (
  sq_idx INTEGER UNSIGNED NOT NULL,
  kf_idx INTEGER UNSIGNED NOT NULL,
  kf_self BOOL NOT NULL DEFAULT FALSE,
  kf_kids BOOL NOT NULL DEFAULT FALSE,
  INDEX sqf_sq_idx(sq_idx),
  INDEX sqf_kf_idx(kf_idx),
  FOREIGN KEY(sq_idx)
    REFERENCES signalquelle(uidx)
      ON DELETE CASCADE
      ON UPDATE NO ACTION,
  FOREIGN KEY(kf_idx)
    REFERENCES kanalfreq(uidx)
      ON DELETE NO ACTION
      ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE utf8_unicode_ci;


-- SIGNALQUELLE - SIGNALBEZUG CONNECTOR ---------------------------------------

CREATE TABLE signalquellensignal (
  sq_idx INTEGER UNSIGNED NOT NULL,
  sb_idx INTEGER UNSIGNED NOT NULL,
  INDEX sbsq_sq_idx(sq_idx),
  INDEX sqsb_sb_idx(sb_idx),
  FOREIGN KEY(sq_idx)
    REFERENCES signalquelle(uidx)
      ON DELETE CASCADE
      ON UPDATE NO ACTION,
  FOREIGN KEY(sb_idx)
    REFERENCES signalbezug(uidx)
      ON DELETE CASCADE
      ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE utf8_unicode_ci;


-- SIGNALQUELLE - SIGNALBEZUG - SIGNALBEZUGPROGRAMM - KANALTABELLE CONNECTOR --

CREATE TABLE signalquellenkanal (
  sq_idx INTEGER UNSIGNED NOT NULL,
  kt_idx INTEGER UNSIGNED NOT NULL,
  kf_self BOOL NOT NULL DEFAULT FALSE,
  kf_kids BOOL NOT NULL DEFAULT FALSE,
  inherited BOOL NOT NULL DEFAULT FALSE,
  INDEX ktsq_sq_idx(sq_idx),
  INDEX sqkt_kt_idx(kt_idx),
  FOREIGN KEY(sq_idx)
    REFERENCES signalquelle(uidx)
      ON DELETE CASCADE
      ON UPDATE NO ACTION,
  FOREIGN KEY(kt_idx)
    REFERENCES kanaltabelle(uidx)
      ON DELETE CASCADE
      ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE utf8_unicode_ci;

-- APPS COMBO BOXES -----------------------------------------------------------

CREATE TABLE combox (
  cbname VARCHAR(16) NOT NULL,
  value SMALLINT UNSIGNED NOT NULL,
  abbr VARCHAR(8) NULL DEFAULT '',
  display1 VARCHAR(256) CHARACTER SET utf8 COLLATE utf8_unicode_ci NULL,
  display2 VARCHAR(256) CHARACTER SET utf8 COLLATE utf8_unicode_ci NULL,
  PRIMARY KEY(cbname, value)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE utf8_unicode_ci;

-- USERS MANAGEMENT -----------------------------------------------------------

CREATE TABLE ktmusers (
  uidx INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
  username VARCHAR(128) NOT NULL,
  passw VARCHAR(128) NOT NULL,
  email VARCHAR(128) NOT NULL,
  name VARCHAR(256) CHARACTER SET utf8 COLLATE utf8_unicode_ci NULL,
  street VARCHAR(256) NULL,
  plz VARCHAR(256) NULL,
  city VARCHAR(256) NULL,
  phone VARCHAR(256) NULL,
  fax VARCHAR(256) NULL,
  lastlogin DATETIME,
  active BOOL DEFAULT TRUE,
  PRIMARY KEY(uidx),
  INDEX ktmu_username(username),
  INDEX ktmu_email(email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE utf8_unicode_ci;

CREATE TABLE ktmroles (
  uidx INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
  rolename VARCHAR(128) NOT NULL,
  credentials INTEGER UNSIGNED NOT NULL,
  PRIMARY KEY(uidx),
  INDEX ktmr_rolename(rolename)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE utf8_unicode_ci;

CREATE TABLE roleofuser (
  user_idx INTEGER UNSIGNED NOT NULL,
  role_idx INTEGER UNSIGNED NOT NULL,
  INDEX rou_user_idx(user_idx),
  INDEX rou_role_idx(role_idx),
  FOREIGN KEY(user_idx)
    REFERENCES ktmusers(uidx)
      ON DELETE CASCADE
      ON UPDATE NO ACTION,
  FOREIGN KEY(role_idx)
    REFERENCES ktmroles(uidx)
      ON DELETE CASCADE
      ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE utf8_unicode_ci;

