CREATE ROLE psfrole;
CREATE USER psfadmin IN GROUP psfrole CREATEDB CREATEROLE PASSWORD 'psfadmin';

CREATE DATABASE psf OWNER psfadmin;

