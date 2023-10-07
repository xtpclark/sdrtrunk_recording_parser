
-- Create a table for checking if file has been moved, deleted, etc.
SELECT psf.create_table('psf_fstat','public');

SELECT 
        psf.add_column('psf_fstat','fs_id',   'integer', 'not null'	,'public', 'FK reference to psf_files.id'),
        psf.add_column('psf_fstat','fs_arch', 'boolean', 'not null default FALSE','public', 'Has file been moved to archive dir'),
        psf.add_column('psf_fstat','fs_del', 'boolean', 'not null default FALSE','public', 'Has file been deleted from archive dir'),
        TRUE;
        
COMMENT ON TABLE public.psf_fstat is 'parsed file archive deleted moved status';

SELECT psf.add_constraint('psf_fstat','psf_fstat_fs_id_psf_files_id_fk','FOREIGN KEY (fs_id) REFERENCES public.psf_files','public');
