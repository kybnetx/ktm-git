
--
-- dummy rows of data tables for their interfacea/connectors which reference
-- them through primary key constrains
--

-- change here AUTO_INCREMENT behaviour
SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";

-- PROGRAMME/BOUQ
INSERT INTO programm (uidx) VALUES (0);

-- SIGNALBEZUG
INSERT INTO sbprovider (uidx) VALUES (0);
INSERT INTO signalbezug (uidx) VALUES (0);

-- KANALTABELLE
INSERT INTO kanalfreq (uidx) VALUES (0);
INSERT INTO kanalfreq (uidx, kanal) VALUES (1, 'LEER');

-- SIGNALQUELLE
INSERT INTO contactoffice (uidx) VALUES (0);

--
-- sqhelper does the folowing jobs for the signalquelle table:
--		- count are children counters for parent nodes
--		- tprev and tnext are pointers to the tree-ordered neighbour nodes
--
--	sqhelper is required because InnoDB cannot:
--		- do additional UPDATE on itself (within trigger) during the transaction
--

INSERT INTO signalquelle (uidx, co_idx) VALUES (0, 0);
INSERT INTO sqhelper (sq_idx, tprev, tnext, count) VALUES (0, 0, 0, 0);

--
-- Pre-Defined Combo Box selections
--

INSERT INTO combox (cbname, value, abbr, display1, display2) VALUES

-- Countries

('delands', 1, '', 'KEINE ANGABE', ''),
('delands', 2, '', 'Baden-Württemberg', ''),
('delands', 3, '', 'Bayern', ''),
('delands', 4, '', 'Berlin', ''),
('delands', 5, '', 'Brandenburg', ''),
('delands', 6, '', 'Bremen', ''),
('delands', 7, '', 'Hamburg', ''),
('delands', 8, '', 'Hessen', ''),
('delands', 9, '', 'Mecklenburg-Vorpommern', ''),
('delands', 10, '', 'Niedersachsen', ''),
('delands', 11, '', 'Nordrhein-Westfalen', ''),
('delands', 12, '', 'Rheinland-Pfalz', ''),
('delands', 13, '', 'Saarland', ''),
('delands', 14, '', 'Sachsen', ''),
('delands', 15, '', 'Sachsen-Anhalt', ''),
('delands', 16, '', 'Schleswig-Holstein', ''),
('delands', 17, '', 'Thüringen', ''),

-- Regions

('deregs', 1, '', 'KEINE ANGABE', ''),
('deregs', 2, '', 'Region 1', ''),
('deregs', 3, '', 'Region 2', ''),
('deregs', 4, '', 'Region 3', ''),

-- "Programm" Types

('pg_type', 1, 'TVP', 'TV', 'TV Programme'),
('pg_type', 2, 'RFP', 'Radio', 'Rundfunk'),
('pg_type', 3, 'BQT', 'Bouquet', 'Bouqete'),
('pg_type', 4, 'DAT', 'Daten', 'Daten'),

-- "Signalquelle" Types

('sq_type', 1, 'KS', 'Kopfstelle', ''),
('sq_type', 2, 'FN', 'Fibernode', ''),
('sq_type', 3, 'HUB', 'Hub', ''),
('sq_type', 4, 'LV', 'Linienverst.', ''),
('sq_type', 5, 'HAV', 'Hausverst.', ''),
('sq_type', 6, 'OBJ', 'Objekt', ''),

-- "Signalbezug" Types

('sb_type', 1, 'SAT', 'Satellit', ''),
('sb_type', 2, 'KAB', 'Kabelnetz', ''),
('sb_type', 3, 'TER', 'Terrestrisch', ''),

-- "Signal" Types

('sig_type', 1, 'ANA', 'Analog', ''),
('sig_type', 2, 'DHD', 'Digital HD', ''),
('sig_type', 3, 'DSD', 'Digital SD', ''),

-- "Broadcast" Types

('bc_type', 1, '', 'MPEG 4:2:2', ''),
('bc_type', 2, '', 'MPEG 1', ''),
('bc_type', 3, '', 'MPEG 1.5', ''),
('bc_type', 4, '', 'MPEG 2', ''),
('bc_type', 5, '', 'MPEG 4', ''),
('bc_type', 6, '', 'MUSE', ''),
('bc_type', 7, '', 'Digicipher 1', ''),
('bc_type', 8, '', 'Digicipher 2', ''),
('bc_type', 9, '', 'ISDB', ''),
('bc_type', 10, '', 'ADR', ''),
('bc_type', 11, '', 'B-MAC', ''),
('bc_type', 12, '', 'D2-MAC', ''),
('bc_type', 13, '', 'WEGE', ''),
('bc_type', 14, '', 'NTSC', ''),
('bc_type', 15, '', 'PAL', ''),
('bc_type', 16, '', 'SECAM', '');


INSERT INTO kanalfreq (kanal, freq1, middfreq, isradio) VALUES

-- S01 - S41 -- TV Kanal --

( 'S01',     0.00,   NULL, 0),
( 'S02',   112.25,   NULL, 0),
( 'S03',   119.25,   NULL, 0),
( 'S04',   126.25,   NULL, 0),
( 'S05',   133.25,   NULL, 0),
( 'S06',   140.25,   NULL, 0),
( 'S07',   147.25,   NULL, 0),
( 'S08',   154.25,   NULL, 0),
( 'S09',   161.25,   NULL, 0),
( 'S10',   168.25,   NULL, 0),
( 'S11',   231.25,   NULL, 0),
( 'S12',   238.25,   NULL, 0),
( 'S13',   245.25,   NULL, 0),
( 'S14',   252.25,   NULL, 0),
( 'S15',   259.26,   NULL, 0),
( 'S16',   266.25,   NULL, 0),
( 'S17',   273.25,   NULL, 0),
( 'S18',   280.25,   NULL, 0),
( 'S19',   287.25,   NULL, 0),
( 'S20',   294.25,   NULL, 0),
( 'S21',   303.25, 306.00, 0),
( 'S22',   311.25, 314.00, 0),
( 'S23',   319.25, 322.00, 0),
( 'S24',   327.25, 330.00, 0),
( 'S25',   335.25, 338.00, 0),
( 'S26',   343.25, 346.00, 0),
( 'S27',   351.25, 354.00, 0),
( 'S28',   359.25, 362.00, 0),
( 'S29',   367.25, 370.00, 0),
( 'S30',   375.25, 378.00, 0),
( 'S31',   383.25, 386.00, 0),
( 'S32',   391.25, 394.00, 0),
( 'S33',   399.25, 402.00, 0),
( 'S34',   407.25, 410.00, 0),
( 'S35',   415.25, 418.00, 0),
( 'S36',   423.25, 426.00, 0),
( 'S37',   431.25, 434.00, 0),
( 'S38',   439.25, 442.00, 0),
( 'S39',   447.25, 450.00, 0),
( 'S40',   455.25, 458.00, 0),
( 'S41',   463.25, 466.00, 0),

-- K01 - K69 -- TV Kanal --
  
( 'K01',     0.00,   NULL, 0),
( 'K02',    48.25,   NULL, 0),
( 'K03',    55.25,   NULL, 0),
( 'K04',    62.25,   NULL, 0),
( 'K05',   175.25,   NULL, 0),
( 'K06',   182.25,   NULL, 0),
( 'K07',   189.25,   NULL, 0),
( 'K08',   196.25,   NULL, 0),
( 'K09',   203.25,   NULL, 0),
( 'K10',   210.25,   NULL, 0),
( 'K11',   217.25,   NULL, 0),
( 'K12',   224.25,   NULL, 0),
( 'K13',     0.00,   NULL, 0),
( 'K14',     0.00,   NULL, 0),
( 'K15',     0.00,   NULL, 0),
( 'K16',     0.00,   NULL, 0),
( 'K17',     0.00,   NULL, 0),
( 'K18',     0.00,   NULL, 0),
( 'K19',     0.00,   NULL, 0),
( 'K20',     0.00,   NULL, 0),
( 'K21',   471.25, 474.00, 0),
( 'K22',   479.25, 482.00, 0),
( 'K23',   487.25, 490.00, 0),
( 'K24',   495.25, 498.00, 0),
( 'K25',   503.25, 506.00, 0),
( 'K26',   511.25, 514.00, 0),
( 'K27',   519.25, 522.00, 0),
( 'K28',   527.25, 530.00, 0),
( 'K29',   535.25, 538.00, 0),
( 'K30',   543.25, 546.00, 0),
( 'K31',   551.25, 554.00, 0),
( 'K32',   559.25, 562.00, 0),
( 'K33',   567.25, 570.00, 0),
( 'K34',   575.25, 578.00, 0),
( 'K35',   583.25, 586.00, 0),
( 'K36',   591.25, 594.00, 0),
( 'K37',   599.25, 602.00, 0),
( 'K38',   607.25, 610.00, 0),
( 'K39',   615.25, 618.00, 0),
( 'K40',   623.25, 626.00, 0),
( 'K41',   631.25, 634.00, 0),
( 'K42',   639.25, 642.00, 0),
( 'K43',   647.25, 650.00, 0),
( 'K44',   655.25, 658.00, 0),
( 'K45',   663.25, 666.00, 0),
( 'K46',   671.25, 674.00, 0),
( 'K47',   679.25, 682.00, 0),
( 'K48',   687.25, 690.00, 0),
( 'K49',   695.25, 698.00, 0),
( 'K50',   703.25, 706.00, 0),
( 'K51',   711.25, 714.00, 0),
( 'K52',   719.25, 722.00, 0),
( 'K53',   727.25, 730.00, 0),
( 'K54',   735.25, 738.00, 0),
( 'K55',   743.25, 746.00, 0),
( 'K56',   751.25, 754.00, 0),
( 'K57',   759.25, 762.00, 0),
( 'K58',   767.25, 770.00, 0),
( 'K59',   775.25, 778.00, 0),
( 'K60',   783.25, 786.00, 0),
( 'K61',   791.25, 794.00, 0),
( 'K62',   799.25, 802.00, 0),
( 'K63',   807.25, 810.00, 0),
( 'K64',   815.25, 818.00, 0),
( 'K65',   823.25, 826.00, 0),
( 'K66',   831.25, 834.00, 0),
( 'K67',   839.25, 842.00, 0),
( 'K68',   847.25, 850.00, 0),
( 'K69',   855.25, 858.00, 0),

-- 87.00 - 108.95 -- Radio FM --

( '87.00',  87.00, NULL, 1),
( '87.05',  87.05, NULL, 1),
( '87.10',  87.10, NULL, 1),
( '87.15',  87.15, NULL, 1),
( '87.20',  87.20, NULL, 1),
( '87.25',  87.25, NULL, 1),
( '87.30',  87.30, NULL, 1),
( '87.35',  87.35, NULL, 1),
( '87.40',  87.40, NULL, 1),
( '87.45',  87.45, NULL, 1),
( '87.50',  87.50, NULL, 1),
( '87.55',  87.55, NULL, 1),
( '87.60',  87.60, NULL, 1),
( '87.65',  87.65, NULL, 1),
( '87.70',  87.70, NULL, 1),
( '87.75',  87.75, NULL, 1),
( '87.80',  87.80, NULL, 1),
( '87.85',  87.85, NULL, 1),
( '87.90',  87.90, NULL, 1),
( '87.95',  87.95, NULL, 1),
( '88.00',  88.00, NULL, 1),
( '88.05',  88.05, NULL, 1),
( '88.10',  88.10, NULL, 1),
( '88.15',  88.15, NULL, 1),
( '88.20',  88.20, NULL, 1),
( '88.25',  88.25, NULL, 1),
( '88.30',  88.30, NULL, 1),
( '88.35',  88.35, NULL, 1),
( '88.40',  88.40, NULL, 1),
( '88.45',  88.45, NULL, 1),
( '88.50',  88.50, NULL, 1),
( '88.55',  88.55, NULL, 1),
( '88.60',  88.60, NULL, 1),
( '88.65',  88.65, NULL, 1),
( '88.70',  88.70, NULL, 1),
( '88.75',  88.75, NULL, 1),
( '88.80',  88.80, NULL, 1),
( '88.85',  88.85, NULL, 1),
( '88.90',  88.90, NULL, 1),
( '88.95',  88.95, NULL, 1),
( '89.00',  89.00, NULL, 1),
( '89.05',  89.05, NULL, 1),
( '89.10',  89.10, NULL, 1),
( '89.15',  89.15, NULL, 1),
( '89.20',  89.20, NULL, 1),
( '89.25',  89.25, NULL, 1),
( '89.30',  89.30, NULL, 1),
( '89.35',  89.35, NULL, 1),
( '89.40',  89.40, NULL, 1),
( '89.45',  89.45, NULL, 1),
( '89.50',  89.50, NULL, 1),
( '89.55',  89.55, NULL, 1),
( '89.60',  89.60, NULL, 1),
( '89.65',  89.65, NULL, 1),
( '89.70',  89.70, NULL, 1),
( '89.75',  89.75, NULL, 1),
( '89.80',  89.80, NULL, 1),
( '89.85',  89.85, NULL, 1),
( '89.90',  89.90, NULL, 1),
( '89.95',  89.95, NULL, 1),
( '90.00',  90.00, NULL, 1),
( '90.05',  90.05, NULL, 1),
( '90.10',  90.10, NULL, 1),
( '90.15',  90.15, NULL, 1),
( '90.20',  90.20, NULL, 1),
( '90.25',  90.25, NULL, 1),
( '90.30',  90.30, NULL, 1),
( '90.35',  90.35, NULL, 1),
( '90.40',  90.40, NULL, 1),
( '90.45',  90.45, NULL, 1),
( '90.50',  90.50, NULL, 1),
( '90.55',  90.55, NULL, 1),
( '90.60',  90.60, NULL, 1),
( '90.65',  90.65, NULL, 1),
( '90.70',  90.70, NULL, 1),
( '90.75',  90.75, NULL, 1),
( '90.80',  90.80, NULL, 1),
( '90.85',  90.85, NULL, 1),
( '90.90',  90.90, NULL, 1),
( '90.95',  90.95, NULL, 1),
( '91.00',  91.00, NULL, 1),
( '91.05',  91.05, NULL, 1),
( '91.10',  91.10, NULL, 1),
( '91.15',  91.15, NULL, 1),
( '91.20',  91.20, NULL, 1),
( '91.25',  91.25, NULL, 1),
( '91.30',  91.30, NULL, 1),
( '91.35',  91.35, NULL, 1),
( '91.40',  91.40, NULL, 1),
( '91.45',  91.45, NULL, 1),
( '91.50',  91.50, NULL, 1),
( '91.55',  91.55, NULL, 1),
( '91.60',  91.60, NULL, 1),
( '91.65',  91.65, NULL, 1),
( '91.70',  91.70, NULL, 1),
( '91.75',  91.75, NULL, 1),
( '91.80',  91.80, NULL, 1),
( '91.85',  91.85, NULL, 1),
( '91.90',  91.90, NULL, 1),
( '91.95',  91.95, NULL, 1),
( '92.00',  92.00, NULL, 1),
( '92.05',  92.05, NULL, 1),
( '92.10',  92.10, NULL, 1),
( '92.15',  92.15, NULL, 1),
( '92.20',  92.20, NULL, 1),
( '92.25',  92.25, NULL, 1),
( '92.30',  92.30, NULL, 1),
( '92.35',  92.35, NULL, 1),
( '92.40',  92.40, NULL, 1),
( '92.45',  92.45, NULL, 1),
( '92.50',  92.50, NULL, 1),
( '92.55',  92.55, NULL, 1),
( '92.60',  92.60, NULL, 1),
( '92.65',  92.65, NULL, 1),
( '92.70',  92.70, NULL, 1),
( '92.75',  92.75, NULL, 1),
( '92.80',  92.80, NULL, 1),
( '92.85',  92.85, NULL, 1),
( '92.90',  92.90, NULL, 1),
( '92.95',  92.95, NULL, 1),
( '93.00',  93.00, NULL, 1),
( '93.05',  93.05, NULL, 1),
( '93.10',  93.10, NULL, 1),
( '93.15',  93.15, NULL, 1),
( '93.20',  93.20, NULL, 1),
( '93.25',  93.25, NULL, 1),
( '93.30',  93.30, NULL, 1),
( '93.35',  93.35, NULL, 1),
( '93.40',  93.40, NULL, 1),
( '93.45',  93.45, NULL, 1),
( '93.50',  93.50, NULL, 1),
( '93.55',  93.55, NULL, 1),
( '93.60',  93.60, NULL, 1),
( '93.65',  93.65, NULL, 1),
( '93.70',  93.70, NULL, 1),
( '93.75',  93.75, NULL, 1),
( '93.80',  93.80, NULL, 1),
( '93.85',  93.85, NULL, 1),
( '93.90',  93.90, NULL, 1),
( '93.95',  93.95, NULL, 1),
( '94.00',  94.00, NULL, 1),
( '94.05',  94.05, NULL, 1),
( '94.10',  94.10, NULL, 1),
( '94.15',  94.15, NULL, 1),
( '94.20',  94.20, NULL, 1),
( '94.25',  94.25, NULL, 1),
( '94.30',  94.30, NULL, 1),
( '94.35',  94.35, NULL, 1),
( '94.40',  94.40, NULL, 1),
( '94.45',  94.45, NULL, 1),
( '94.50',  94.50, NULL, 1),
( '94.55',  94.55, NULL, 1),
( '94.60',  94.60, NULL, 1),
( '94.65',  94.65, NULL, 1),
( '94.70',  94.70, NULL, 1),
( '94.75',  94.75, NULL, 1),
( '94.80',  94.80, NULL, 1),
( '94.85',  94.85, NULL, 1),
( '94.90',  94.90, NULL, 1),
( '94.95',  94.95, NULL, 1),
( '95.00',  95.00, NULL, 1),
( '95.05',  95.05, NULL, 1),
( '95.10',  95.10, NULL, 1),
( '95.15',  95.15, NULL, 1),
( '95.20',  95.20, NULL, 1),
( '95.25',  95.25, NULL, 1),
( '95.30',  95.30, NULL, 1),
( '95.35',  95.35, NULL, 1),
( '95.40',  95.40, NULL, 1),
( '95.45',  95.45, NULL, 1),
( '95.50',  95.50, NULL, 1),
( '95.55',  95.55, NULL, 1),
( '95.60',  95.60, NULL, 1),
( '95.65',  95.65, NULL, 1),
( '95.70',  95.70, NULL, 1),
( '95.75',  95.75, NULL, 1),
( '95.80',  95.80, NULL, 1),
( '95.85',  95.85, NULL, 1),
( '95.90',  95.90, NULL, 1),
( '95.95',  95.95, NULL, 1),
( '96.00',  96.00, NULL, 1),
( '96.05',  96.05, NULL, 1),
( '96.10',  96.10, NULL, 1),
( '96.15',  96.15, NULL, 1),
( '96.20',  96.20, NULL, 1),
( '96.25',  96.25, NULL, 1),
( '96.30',  96.30, NULL, 1),
( '96.35',  96.35, NULL, 1),
( '96.40',  96.40, NULL, 1),
( '96.45',  96.45, NULL, 1),
( '96.50',  96.50, NULL, 1),
( '96.55',  96.55, NULL, 1),
( '96.60',  96.60, NULL, 1),
( '96.65',  96.65, NULL, 1),
( '96.70',  96.70, NULL, 1),
( '96.75',  96.75, NULL, 1),
( '96.80',  96.80, NULL, 1),
( '96.85',  96.85, NULL, 1),
( '96.90',  96.90, NULL, 1),
( '96.95',  96.95, NULL, 1),
( '97.00',  97.00, NULL, 1),
( '97.05',  97.05, NULL, 1),
( '97.10',  97.10, NULL, 1),
( '97.15',  97.15, NULL, 1),
( '97.20',  97.20, NULL, 1),
( '97.25',  97.25, NULL, 1),
( '97.30',  97.30, NULL, 1),
( '97.35',  97.35, NULL, 1),
( '97.40',  97.40, NULL, 1),
( '97.45',  97.45, NULL, 1),
( '97.50',  97.50, NULL, 1),
( '97.55',  97.55, NULL, 1),
( '97.60',  97.60, NULL, 1),
( '97.65',  97.65, NULL, 1),
( '97.70',  97.70, NULL, 1),
( '97.75',  97.75, NULL, 1),
( '97.80',  97.80, NULL, 1),
( '97.85',  97.85, NULL, 1),
( '97.90',  97.90, NULL, 1),
( '97.95',  97.95, NULL, 1),
( '98.00',  98.00, NULL, 1),
( '98.05',  98.05, NULL, 1),
( '98.10',  98.10, NULL, 1),
( '98.15',  98.15, NULL, 1),
( '98.20',  98.20, NULL, 1),
( '98.25',  98.25, NULL, 1),
( '98.30',  98.30, NULL, 1),
( '98.35',  98.35, NULL, 1),
( '98.40',  98.40, NULL, 1),
( '98.45',  98.45, NULL, 1),
( '98.50',  98.50, NULL, 1),
( '98.55',  98.55, NULL, 1),
( '98.60',  98.60, NULL, 1),
( '98.65',  98.65, NULL, 1),
( '98.70',  98.70, NULL, 1),
( '98.75',  98.75, NULL, 1),
( '98.80',  98.80, NULL, 1),
( '98.85',  98.85, NULL, 1),
( '98.90',  98.90, NULL, 1),
( '98.95',  98.95, NULL, 1),
( '99.00',  99.00, NULL, 1),
( '99.05',  99.05, NULL, 1),
( '99.10',  99.10, NULL, 1),
( '99.15',  99.15, NULL, 1),
( '99.20',  99.20, NULL, 1),
( '99.25',  99.25, NULL, 1),
( '99.30',  99.30, NULL, 1),
( '99.35',  99.35, NULL, 1),
( '99.40',  99.40, NULL, 1),
( '99.45',  99.45, NULL, 1),
( '99.50',  99.50, NULL, 1),
( '99.55',  99.55, NULL, 1),
( '99.60',  99.60, NULL, 1),
( '99.65',  99.65, NULL, 1),
( '99.70',  99.70, NULL, 1),
( '99.75',  99.75, NULL, 1),
( '99.80',  99.80, NULL, 1),
( '99.85',  99.85, NULL, 1),
( '99.90',  99.90, NULL, 1),
( '99.95',  99.95, NULL, 1),
('100.00', 100.00, NULL, 1),
('100.05', 100.05, NULL, 1),
('100.10', 100.10, NULL, 1),
('100.15', 100.15, NULL, 1),
('100.20', 100.20, NULL, 1),
('100.25', 100.25, NULL, 1),
('100.30', 100.30, NULL, 1),
('100.35', 100.35, NULL, 1),
('100.40', 100.40, NULL, 1),
('100.45', 100.45, NULL, 1),
('100.50', 100.50, NULL, 1),
('100.55', 100.55, NULL, 1),
('100.60', 100.60, NULL, 1),
('100.65', 100.65, NULL, 1),
('100.70', 100.70, NULL, 1),
('100.75', 100.75, NULL, 1),
('100.80', 100.80, NULL, 1),
('100.85', 100.85, NULL, 1),
('100.90', 100.90, NULL, 1),
('100.95', 100.95, NULL, 1),
('101.00', 101.00, NULL, 1),
('101.05', 101.05, NULL, 1),
('101.10', 101.10, NULL, 1),
('101.15', 101.15, NULL, 1),
('101.20', 101.20, NULL, 1),
('101.25', 101.25, NULL, 1),
('101.30', 101.30, NULL, 1),
('101.35', 101.35, NULL, 1),
('101.40', 101.40, NULL, 1),
('101.45', 101.45, NULL, 1),
('101.50', 101.50, NULL, 1),
('101.55', 101.55, NULL, 1),
('101.60', 101.60, NULL, 1),
('101.65', 101.65, NULL, 1),
('101.70', 101.70, NULL, 1),
('101.75', 101.75, NULL, 1),
('101.80', 101.80, NULL, 1),
('101.85', 101.85, NULL, 1),
('101.90', 101.90, NULL, 1),
('101.95', 101.95, NULL, 1),
('102.00', 102.00, NULL, 1),
('102.05', 102.05, NULL, 1),
('102.10', 102.10, NULL, 1),
('102.15', 102.15, NULL, 1),
('102.20', 102.20, NULL, 1),
('102.25', 102.25, NULL, 1),
('102.30', 102.30, NULL, 1),
('102.35', 102.35, NULL, 1),
('102.40', 102.40, NULL, 1),
('102.45', 102.45, NULL, 1),
('102.50', 102.50, NULL, 1),
('102.55', 102.55, NULL, 1),
('102.60', 102.60, NULL, 1),
('102.65', 102.65, NULL, 1),
('102.70', 102.70, NULL, 1),
('102.75', 102.75, NULL, 1),
('102.80', 102.80, NULL, 1),
('102.85', 102.85, NULL, 1),
('102.90', 102.90, NULL, 1),
('102.95', 102.95, NULL, 1),
('103.00', 103.00, NULL, 1),
('103.05', 103.05, NULL, 1),
('103.10', 103.10, NULL, 1),
('103.15', 103.15, NULL, 1),
('103.20', 103.20, NULL, 1),
('103.25', 103.25, NULL, 1),
('103.30', 103.30, NULL, 1),
('103.35', 103.35, NULL, 1),
('103.40', 103.40, NULL, 1),
('103.45', 103.45, NULL, 1),
('103.50', 103.50, NULL, 1),
('103.55', 103.55, NULL, 1),
('103.60', 103.60, NULL, 1),
('103.65', 103.65, NULL, 1),
('103.70', 103.70, NULL, 1),
('103.75', 103.75, NULL, 1),
('103.80', 103.80, NULL, 1),
('103.85', 103.85, NULL, 1),
('103.90', 103.90, NULL, 1),
('103.95', 103.95, NULL, 1),
('104.00', 104.00, NULL, 1),
('104.05', 104.05, NULL, 1),
('104.10', 104.10, NULL, 1),
('104.15', 104.15, NULL, 1),
('104.20', 104.20, NULL, 1),
('104.25', 104.25, NULL, 1),
('104.30', 104.30, NULL, 1),
('104.35', 104.35, NULL, 1),
('104.40', 104.40, NULL, 1),
('104.45', 104.45, NULL, 1),
('104.50', 104.50, NULL, 1),
('104.55', 104.55, NULL, 1),
('104.60', 104.60, NULL, 1),
('104.65', 104.65, NULL, 1),
('104.70', 104.70, NULL, 1),
('104.75', 104.75, NULL, 1),
('104.80', 104.80, NULL, 1),
('104.85', 104.85, NULL, 1),
('104.90', 104.90, NULL, 1),
('104.95', 104.95, NULL, 1),
('105.00', 105.00, NULL, 1),
('105.05', 105.05, NULL, 1),
('105.10', 105.10, NULL, 1),
('105.15', 105.15, NULL, 1),
('105.20', 105.20, NULL, 1),
('105.25', 105.25, NULL, 1),
('105.30', 105.30, NULL, 1),
('105.35', 105.35, NULL, 1),
('105.40', 105.40, NULL, 1),
('105.45', 105.45, NULL, 1),
('105.50', 105.50, NULL, 1),
('105.55', 105.55, NULL, 1),
('105.60', 105.60, NULL, 1),
('105.65', 105.65, NULL, 1),
('105.70', 105.70, NULL, 1),
('105.75', 105.75, NULL, 1),
('105.80', 105.80, NULL, 1),
('105.85', 105.85, NULL, 1),
('105.90', 105.90, NULL, 1),
('105.95', 105.95, NULL, 1),
('106.00', 106.00, NULL, 1),
('106.05', 106.05, NULL, 1),
('106.10', 106.10, NULL, 1),
('106.15', 106.15, NULL, 1),
('106.20', 106.20, NULL, 1),
('106.25', 106.25, NULL, 1),
('106.30', 106.30, NULL, 1),
('106.35', 106.35, NULL, 1),
('106.40', 106.40, NULL, 1),
('106.45', 106.45, NULL, 1),
('106.50', 106.50, NULL, 1),
('106.55', 106.55, NULL, 1),
('106.60', 106.60, NULL, 1),
('106.65', 106.65, NULL, 1),
('106.70', 106.70, NULL, 1),
('106.75', 106.75, NULL, 1),
('106.80', 106.80, NULL, 1),
('106.85', 106.85, NULL, 1),
('106.90', 106.90, NULL, 1),
('106.95', 106.95, NULL, 1),
('107.00', 107.00, NULL, 1),
('107.05', 107.05, NULL, 1),
('107.10', 107.10, NULL, 1),
('107.15', 107.15, NULL, 1),
('107.20', 107.20, NULL, 1),
('107.25', 107.25, NULL, 1),
('107.30', 107.30, NULL, 1),
('107.35', 107.35, NULL, 1),
('107.40', 107.40, NULL, 1),
('107.45', 107.45, NULL, 1),
('107.50', 107.50, NULL, 1),
('107.55', 107.55, NULL, 1),
('107.60', 107.60, NULL, 1),
('107.65', 107.65, NULL, 1),
('107.70', 107.70, NULL, 1),
('107.75', 107.75, NULL, 1),
('107.80', 107.80, NULL, 1),
('107.85', 107.85, NULL, 1),
('107.90', 107.90, NULL, 1),
('107.95', 107.95, NULL, 1),
('108.00', 108.00, NULL, 1),
('108.05', 108.05, NULL, 1),
('108.10', 108.10, NULL, 1),
('108.15', 108.15, NULL, 1),
('108.20', 108.20, NULL, 1),
('108.25', 108.25, NULL, 1),
('108.30', 108.30, NULL, 1),
('108.35', 108.35, NULL, 1),
('108.40', 108.40, NULL, 1),
('108.45', 108.45, NULL, 1),
('108.50', 108.50, NULL, 1),
('108.55', 108.55, NULL, 1),
('108.60', 108.60, NULL, 1),
('108.65', 108.65, NULL, 1),
('108.70', 108.70, NULL, 1),
('108.75', 108.75, NULL, 1),
('108.80', 108.80, NULL, 1),
('108.85', 108.85, NULL, 1),
('108.90', 108.90, NULL, 1),
('108.95', 108.95, NULL, 1);


