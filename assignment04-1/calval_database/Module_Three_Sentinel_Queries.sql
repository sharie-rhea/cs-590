-- create indices for faster lookups
CREATE INDEX fdes_index ON digestmess.fdes("Cn code");
CREATE INDEX wght_index ON digestmess.wght("Cn code", "Sequence num");
CREATE INDEX gpcnme_index ON digestmess.gpcnme("Gpc code");
CREATE INDEX ctgnme_index ON digestmess.ctgnme("Food category code");

-- 8976, 15052, 131, 25
select count(*) from digestmess.fdes;
select count(*) from digestmess.wght;
select count(*) from digestmess.gpcnme;
select count(*) from digestmess.ctgnme;
