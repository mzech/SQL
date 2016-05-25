CREATE                      PROCEDURE [dbo].[usp_EmailNotification] 
				@Export_Import_ID	Varchar(25)    
AS

--	EXEC  usp_Import_EmailNotification '101'

Set NoCount ON
	
declare @ServerName 	VARCHAR(50),	@rc int, 	
	@MessageText	varchar(1255),	@Subject	Varchar(200),
	@FromList	Varchar(200),	@FromName	Varchar(200),
	@ToList		Varchar(200),	@CCList		Varchar(200),
	@BccList	Varchar(200),	@PhoneNumber	Varchar(50),
	@ProcessName Varchar(200),
	@ClientName		Varchar(100),
	@Contactperson varchar(100)
SET 	@ServerName 	= @@ServerName
print 	@ServerName

Set	@FromList	= (Select FromList from EmailNotification where Export_Import_ID = @Export_Import_ID AND Active = 1)
Set	@FromList	= (Select FromList from EmailNotification where Export_Import_ID = @Export_Import_ID AND Active = 1)
Set	@FromName	= (Select FromName from EmailNotification where Export_Import_ID = @Export_Import_ID AND Active = 1)
Set	@ToList		= (Select ToList from EmailNotification where Export_Import_ID = @Export_Import_ID AND Active = 1)
Set	@CCList		= (Select CCList from EmailNotification where Export_Import_ID = @Export_Import_ID AND Active = 1)
Set	@BccList	= (Select BccList from EmailNotification where Export_Import_ID = @Export_Import_ID AND Active = 1)
Set	@ClientName		= (Select ClientName from EmailNotification where Export_Import_ID = @Export_Import_ID AND Active = 1)
Set	@PhoneNumber	= (Select PhoneNumber from EmailNotification where Export_Import_ID = @Export_Import_ID AND Active = 1)
Set	@ProcessName	= (Select ProcessName from EmailNotification where Export_Import_ID = @Export_Import_ID AND Active = 1)
Set	@ContactPerson	= (Select ContactPerson from EmailNotification where Export_Import_ID = @Export_Import_ID AND Active = 1)

--	Select * from EmailNotification
Print 'FromList - ' + @FromList 
Print 'FromList - ' + @FromList 
Print '@FromName - ' + @FromName 
Print '@ToList - ' + @ToList 
Print '@CCList - ' + @CCList 
Print '@BccList - ' + @BccList 



--Goto SendMail
Set	@Subject	= @ProcessName +  convert(varchar(20), getdate(), 101) + ' has been processed. '
Set	@MessageText = @ProcessName + 'Has been processed Successfully.
Please review the errors and try to have them corrected for the next file. If you have any questions please contact the developer' + @ContactPerson + ' at ' + @PhoneNumber + ' to assist with error resolution.  Thanks! '

Print 'Subject - ' + @Subject 

If @@ServerName = 'Albacore\Tuna'
--select @@servername


	Begin 		Goto SendMail		End

If @@ServerName <> 'Albacore\Tuna'
		Begin
			Goto	Proc_End
		End
	
	
	SendMail:
				EXEC msdb.dbo.sp_send_dbmail
						 @profile_name					= 'dbmail'
						,@recipients					= 'mzech@ercbpo.com' --@ToList
						,@subject						= @Subject
						,@body							= @MessageText
						,@body_format					= 'HTML'
						,@from_Address					= 'Recordings <reporting@ercbpo.com>' --@FromName	



Print convert(Varchar(30),getdate(),9) + ' - Emailed sent'

Proc_End:
