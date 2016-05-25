Create PROCEDURE [dbo].[time_delay] @@DELAYLENGTH varchar(9), @PrintInd bit = 0
AS
/*
	-- This next statement executes the time_delay procedure.
	EXEC time_delay '000:00:02', 1
*/
DECLARE @@RETURNINFO varchar(255)
BEGIN
   WAITFOR DELAY @@DELAYLENGTH
   SELECT @@RETURNINFO = 'A total time of ' + 
                  SUBSTRING(@@DELAYLENGTH, 1, 3) +
                  ' hours, ' +
                  SUBSTRING(@@DELAYLENGTH, 5, 2) + 
                  ' minutes, and ' +
                  SUBSTRING(@@DELAYLENGTH, 8, 2) + 
                  ' seconds, ' +
                  'has elapsed!'

If @PrintInd = 1
Begin    PRINT @@RETURNINFO END
end