

CREATE procedure [dbo].[ercudp_Export_Import_Error_Log_Detail] @Export_Import_ID int, @reportDate DATETime 

AS


--==================================================================================================================================================
--HISTORY
--==================================================================================================================================================
--01/29/16 - MZ - Created
--Long Running handles all frequency and is based on the log.
--Albacore currently has
--          Daily	Day Once a Day 
--			Daily	HOUR	incremented
--			Daily	MINUTE	incremented
--			Weekly	DAY	-Once
--==================================================================================================================================================
BEGIN


If @Reportdate is null
	SET @ReportDate = GETDATE()

	
--declare @startDate DATE = CAST(@reportDate AS datetime) - 1
--declare @endDate DATE = @reportDate
Print @ReportDate
Print @Export_Import_ID
--Delete filehistory over 30 days -This is so the table doesn't become too large
Delete from  Export_Import_FileHistory where
CompleteDatetime<=(getdate()-30)

--==================================================================================
--Long Running all frequency modes 
--==================================================================================
Print 'LongRunning'
;with D as (Select s.export_import_id, h.fileid,timeofDay, Frequency, FrequencyType, minuteincrement,hourincrement,DayofWeek, 
	c.ProcessTypeID,s.Clientname,Export_Import_Description, jobname,datediff(minute,startdatetime,completedatetime) 
	as 'Minutes'
		from Export_import_filehistory h
		inner join export_import_schedule s on (s.export_import_id=h.export_import_id) and s.active='1'
		inner join export_import_list l on (l.export_import_id=h.export_import_id)
			inner join export_import_codes c on (c.export_import_id=h.export_import_id)
		where convert(date,completedatetime)=convert(date,getdate()) and fileid=(Select MAX(fileid) 
		from Export_Import_FileHistory where export_import_id=@Export_Import_ID and completedatetime is not null )
		and datediff(minute,startdatetime,completedatetime) >=90)
	

	INSERT INTO [dbo].[Export_Import_Error_Log]
           ([FileDueDate]
           ,[Export_Import_ID]
           ,[ProcessTypeID]
           ,[ClientName]
		   ,Jobname
           ,[Export_Import_Description]
		   ,[Fileid] 
           ,[ErrorMessage])
	Select 
			isnull(@ReportDate,getdate())
           ,[Export_Import_ID]
           ,[ProcessTypeID]
           ,[ClientName]
		   ,jobname
           ,[Export_Import_Description]
		   , fileid
           ,('Process is taking a long time to execute. Runtime was ' + convert(varchar, d.minutes) + ' Minutes' )
	from D
	where d.fileid not in (Select l.fileid from export_import_error_log l where l.fileid=d.fileid)

--===================================================================================
--Missing Log entry. This is the schedule Frequencies in the export_import_schedule
--===================================================================================
--Daily - Minute
--===================================================================================

--Job runs every 20 minutes --Use @MinInc as the threshold
Declare @MinInc int
Set @MinInc=(Select Distinct isnull(minuteincrement,0)+20 from export_import_schedule 
where export_import_ID=@Export_Import_ID and active='1' and minuteincrement<>0)

If @MinInc>0 
Begin
--Minutes. If missing send alert
--This will pull all that should have run and it will also if it did run exclude any run that still has time on the clock before it is due again
Print 'Minute'
;with D as (Select s.export_import_id, timeofDay, Frequency, FrequencyType, minuteincrement,hourincrement,DayofWeek, 
	c.ProcessTypeID,s.Clientname,Export_Import_Description,jobname
	from export_import_schedule s 
	inner join export_import_list l on (l.export_import_id=s.export_import_id)
	inner join export_import_codes c on (c.export_import_id=s.export_import_id)
		where s.active='1' and s.FrequencyType='Minute' 
		and s.minuteincrement>0
		and datepart(hh,getdate())>=timeofday 
		and s.export_import_id=@Export_Import_ID
		and s.export_import_id not in (Select export_import_id 
		from export_Import_FileHistory 
		where fileid=(Select MAX(fileid) from Export_Import_FileHistory where export_import_id=@Export_Import_ID
		and (completedatetime>= dateadd(minute,-@MinInc,GETDATE()) or 
		completedatetime is null))))  --Less than will exclude those that still have time.

--Select * from export_import_schedule

	INSERT INTO [dbo].[Export_Import_Error_Log]
           ([FileDueDate]
           ,[Export_Import_ID]
           ,[ProcessTypeID]
           ,[ClientName]
           ,[Export_Import_Description]
		   ,jobname
           ,[ErrorMessage])
	Select 
			@ReportDate
           ,d.[Export_Import_ID]
           ,[ProcessTypeID]
           ,[ClientName]
           ,[Export_Import_Description]
		   ,jobname
           ,('Process was not run on time. Runs every '+ convert(varchar,isnull(minuteincrement,0))+ ' minutes. Last Run was at ' 
		   + isnull(convert(varchar,h.completedatetime),'01/01/1950'))
	from D
	left join export_import_filehistory h on (h.export_import_id=d.export_import_id)
	where h.fileid in (Select max(fileid) from export_import_filehistory ex where ex.export_import_id=d.export_import_id)
	
	union

		Select 
			@ReportDate
           ,d.[Export_Import_ID]
           ,[ProcessTypeID]
           ,d.[ClientName]
           ,[Export_Import_Description]
		   ,jobname
           ,('Process was not run on time. Runs every '+ convert(varchar,s.minuteincrement)+ ' minutes.')
	from D
	left join export_import_schedule s on (s.export_import_id=d.export_import_id) and s.active='1'
	where d.export_import_id not in (Select ex.export_import_id from export_import_filehistory ex 
	where ex.export_import_id=d.export_import_id
	and ex.completedatetime>=getdate())
End
	
--Select * from export_import_error_log

--===================================================================================
--Daily - Hour incremented
--===================================================================================

--Job Runs every 20 minutes
Declare @HRInc int
Set @HRInc=(Select Distinct isnull(hourincrement,0)+1 from export_import_schedule where export_import_ID=@Export_Import_ID 
and active='1' and hourincrement<>0)

If @HRInc>0
Begin
Print'Hour'
--Hours. If missing send alert
;with D as (Select s.export_import_id, timeofDay, Frequency, FrequencyType, minuteincrement,hourincrement,DayofWeek, 
	c.ProcessTypeID,s.Clientname,Export_Import_Description,jobname
	from export_import_schedule s 
	inner join export_import_list l on (l.export_import_id=s.export_import_id)
	inner join export_import_codes c on (c.export_import_id=s.export_import_id)
		where s.active='1' and s.FrequencyType='Hour'
		and s.hourincrement<>0 
		and s.export_import_id=@Export_Import_ID
		and datepart(hh,getdate())>=timeofday 
		and s.export_import_id not in 
				(Select export_import_id 
					from export_Import_FileHistory 
					where fileid=(Select MAX(fileid) from Export_Import_FileHistory where export_import_id=@Export_Import_ID
					and (completedatetime>= dateadd(hour,-@HRInc,GETDATE())or 
					completedatetime is null))))

	
	INSERT INTO [dbo].[Export_Import_Error_Log]
           ([FileDueDate]
           ,[Export_Import_ID]
           ,[ProcessTypeID]
           ,[ClientName]
           ,[Export_Import_Description]
		   ,jobname
           ,[ErrorMessage])
	Select 
			@ReportDate
           ,d.[Export_Import_ID]
           ,[ProcessTypeID]
           ,[ClientName]
           ,[Export_Import_Description]
		   ,jobname
           ,('Process was not run on time. Runs every '+ convert(varchar,hourincrement)+ ' hour. Last Run was at ' 
		   + convert(varchar,h.completedatetime))
	from D
	left join export_import_filehistory h on (h.export_import_id=d.export_import_id)
	where h.fileid in (Select max(fileid) from export_import_filehistory ex where ex.export_import_id=d.export_import_id
	and completedatetime is not null)
		--COMPLETELY MISSING FROM LOG
	union

		Select 
			@ReportDate
           ,d.[Export_Import_ID]
           ,[ProcessTypeID]
           ,d.[ClientName]
           ,[Export_Import_Description]
		   ,jobname
           ,('Process was not run on time. Runs every '+ convert(varchar,s.hourincrement)+ ' hour.')
	from D
	left join export_import_schedule s on (s.export_import_id=d.export_import_id) and s.active='1'
	where d.export_import_id not in (Select ex.export_import_id from export_import_filehistory ex 
	where ex.export_import_id=d.export_import_id
	and ex.completedatetime>=getdate())


End	
--Select * from export_import_error_log

--================================================================================================
--Daily - Hour incremented and Minute Increment = 0 = This means the feed is only once a day
--Use TimeofDay
--==================================================================================================


Declare @Time int
Set @Time=(Select Distinct isnull(Timeofday,0) from export_import_schedule where export_import_ID=@Export_Import_ID and active='1')
Print @Time


If EXISTS(Select export_import_id from export_import_schedule where export_import_ID=@Export_Import_ID and active='1'
			and frequency='Daily' and frequencytype='Day' and minuteincrement=0 and hourincrement=0)

Begin
Print 'Day'
;with D as (Select s.export_import_id, timeofDay, Frequency, FrequencyType, minuteincrement,hourincrement,DayofWeek, 
	c.ProcessTypeID,s.Clientname,Export_Import_Description,jobname
	from export_import_schedule s 
	inner join export_import_list l on (l.export_import_id=s.export_import_id)
	inner join export_import_codes c on (c.export_import_id=s.export_import_id)
	where s.active='1' and s.FrequencyType='DAY' 
		and Frequency='Daily'
		and datepart(hh,getdate())>=timeofday --Don't report until after it is due
		and s.export_import_id=@Export_Import_ID
		and s.export_import_id not in 
					(Select export_import_id 
					from export_Import_FileHistory 
					where fileid=(Select MAX(fileid) from Export_Import_FileHistory where export_import_id=@Export_Import_ID
					and datepart(hh,getdate())>=timeofday )
					and convert(date,CompleteDatetime)=convert(date,getdate())))


	
	INSERT INTO [dbo].[Export_Import_Error_Log]
           ([FileDueDate]
           ,[Export_Import_ID]
           ,[ProcessTypeID]
           ,[ClientName]
           ,[Export_Import_Description]
		   ,jobname
           ,[ErrorMessage])
	Select 
			@ReportDate
           ,d.[Export_Import_ID]
           ,[ProcessTypeID]
           ,[ClientName]
           ,[Export_Import_Description]
		   ,jobname
           ,('Process was not run on time. Runs once a day at '+ convert(varchar,d.timeofday)+'. Last Run was on ' 
		   + convert(varchar,h.completedatetime))
	from D
	left join export_import_filehistory h on (h.export_import_id=d.export_import_id)
	where h.fileid in (Select max(fileid) from export_import_filehistory ex where ex.export_import_id=d.export_import_id
	and completedatetime is not null)
	
	--Completely missing from log
	union

		Select 
			@ReportDate
           ,d.[Export_Import_ID]
           ,[ProcessTypeID]
           ,d.[ClientName]
           ,[Export_Import_Description]
		   ,jobname
           ,('Process was not run on time. Runs once a day at '+ convert(varchar,s.timeofday))
	from D
	left join export_import_schedule s on (s.export_import_id=d.export_import_id) and s.active='1'
	where d.export_import_id not in (Select ex.export_import_id from export_import_filehistory ex 
	where ex.export_import_id=d.export_import_id
	and ex.completedatetime>=getdate())

End	
--=========================================================================================
--Weekly - Per Day
--=========================================================================================

If exists (Select dayofweek from export_import_schedule where export_import_ID=@Export_Import_Id
			and dayofweek in (Select description from codes_dayofweekid where
			sortorder=datepart(w,getdate()) ))


Print 'Weekly - PerDay'
Begin
	;with D as (Select ex.export_import_id, timeofDay,Frequency, FrequencyType,DayofWeek, 
	c.ProcessTypeID,ex.Clientname,Export_Import_Description,jobname
	from export_import_schedule ex
	inner join export_import_list l on (l.export_import_id=ex.export_import_id)
	inner join export_import_codes c on (c.export_import_id=ex.export_import_id)
	inner join codes_dayofweekid w on (w.Description=ex.dayofweek)
	where FrequencyType='Day' 
	and Frequency='Weekly'
	and ex.active='1'
	and datepart(hh,getdate())>=timeofday
	and w.sortorder= datepart(w,getdate())
	and ex.export_import_id=@Export_Import_ID
		and ex.export_import_id not in 
					(Select export_import_id 
					from export_Import_FileHistory 
					where fileid=(Select MAX(fileid) from Export_Import_FileHistory where export_import_id=@Export_Import_ID
					and datepart(hh,getdate())>=timeofday )
					and convert(date,CompleteDatetime)=convert(date,getdate())))


	INSERT INTO [dbo].[Export_Import_Error_Log]
           ([FileDueDate]
           ,[Export_Import_ID]
           ,[ProcessTypeID]
           ,[ClientName]
           ,[Export_Import_Description]
		   ,jobname
           ,[ErrorMessage])
	Select 
			@ReportDate
           ,d.[Export_Import_ID]
           ,[ProcessTypeID]
           ,[ClientName]
           ,[Export_Import_Description]
		   ,jobname
			,('Process was not run on time. Runs once a week on'+ convert(varchar,d.dayofweek)+'. Last Run was on ' 
		   + convert(varchar,h.completedatetime))
	from D
	left join export_import_filehistory h on (h.export_import_id=d.export_import_id)
	where h.fileid in (Select max(fileid) from export_import_filehistory ex where ex.export_import_id=d.export_import_id
	and completedatetime is not null)

		union

		Select 
			@ReportDate
           ,d.[Export_Import_ID]
           ,[ProcessTypeID]
           ,d.[ClientName]
           ,[Export_Import_Description]
		   ,jobname
           ,('Process was not run on time. Runs once a week on '+ convert(varchar,s.dayofweek))
	from D
	left join export_import_schedule s on (s.export_import_id=d.export_import_id) and s.active='1'
	where d.export_import_id not in (Select ex.export_import_id from export_import_filehistory ex 
	where ex.export_import_id=d.export_import_id
	and ex.completedatetime>=getdate())


	End

--============================================================================================================================
--Hard Close on Schedule - Remove any errors after the TimeofDay_Stop
--============================================================================================================================
--Example:Some jobs run frmo 2am to 2pm - remove any errors after 2pm

If exists (Select timeofday_stop from export_import_schedule where export_import_ID=@Export_Import_Id
			and timeofday_stop<>0)

Begin
Print 'RemoveOverLimit'
Delete from export_import_error_log 
where export_import_ID=@Export_Import_Id and fileduedate=@ReportDate
and export_import_id in (Select s.export_import_id from export_import_schedule s where export_import_ID=s.Export_Import_Id
			and timeofday_stop<datepart(hh,@ReportDate))
End



--Remove feed errors that ran from 11:00pm to 12:00 that are due at midnight or before that were run
If exists (Select timeofday from export_import_schedule where export_import_ID=@Export_Import_Id
			and timeofday='0' and frequency='Daily' and frequencytype='Day')

Begin


Delete from export_import_error_log 
where export_import_ID=@Export_Import_Id and convert(date,fileduedate)=convert(date,getdate())
and export_import_id in (Select h.export_import_id from export_import_filehistory h where export_import_ID=h.Export_Import_Id
			and h.completedatetime >= dateadd(hour,-24,@ReportDate)  )
			

End


--Remove errors on Days that are not active
If exists (Select * from export_import_schedule 
			where export_import_ID=@Export_Import_Id
			--and frequency='Daily' and frequencytype='Day'
			and dayofweek is not null 
			and active='1')

Begin
--these are on a set date - Do not report on days they are not run
Delete from export_import_error_log 
where convert(date,fileduedate)=convert(date,getdate())
and export_import_ID=@Export_Import_Id
and export_import_id not in (Select export_import_id from export_import_schedule s 
								inner join codes_dayofweekid c on (s.dayofweek=c.description)
								where s.export_import_id=@export_import_id
								and c.sortorder=datepart(w,getdate()))

								
End

End
----============================================================================================================================
----EMAIL RESULTS
----============================================================================================================================

--DECLARE @tableHTML NVARCHAR(MAX)
--SET @tableHTML	=
--	N'<h1 style="color:black; font-family:Garamond;">Albacore and ERCSportster Export_Import Process Report</h1>'	+
--	N'<table border="1">'	+
--	N'	<tr>'	+
--	N'		<th>FileDueDate</th>'	+
--	N'		<th>Export_Import_ID</th>'	+
--	N'		<th>ProcessTypeID</th>'		+
--	N'		<th>Export_Import_Description</th>'	+
--	N'		<th>ErrorMessage</th>'	+
--	N'	</tr>'	+

--	CAST(
--			(SELECT
--				 td	=	T.FileDueDate	,''
--				,td	=	T.Export_Import_ID		,''
--				,td	=	T.ProcessTypeID		,''
--				,td	=	isnull(Export_Import_Description,'')	,''
--				,td	=	T.ErrorMessage	,''
--				FROM Export_Import_Error_Log AS T
--				where FileDueDate	=	@ReportDate
--				order by T.Export_Import_ID
--				FOR XML PATH('tr'),TYPE
				
--			) AS NVARCHAR(MAX)
--		) +
--	N'</table>';

--IF EXISTS(SELECT * FROM Export_Import_Error_Log 
--				where FileDueDate	=	@ReportDate
--		 ) 

--		BEGIN 
--						EXEC msdb.dbo.sp_send_dbmail
--						 @profile_name					= 'dbmail'
--						,@recipients					= 'mzech@ercbpo.com'--itmralerts@ercbpo.com'
--						--,@copy_recipients				= 
--						,@subject						= 'Albacore and ERCSportster Export_Import Process Report'
--						,@body							= @tableHTML
--						,@body_format					= 'HTML'
--						,@from_address					= 'Reporting<reporting@ercbpo.com>'
--						--,@file_attachments				= 'd:\temp\file.txt'
						
		
--		End

--		Else

--		PRINT'NO RESULTS TO OUTPUT'




--End

--exec ercudp_Export_Import_Error_Log_Detail '110',	null
--Select * from export_import_error_log 

--Declare @Int int
--Set @Int=(Select max(export_import_id) from export_import_schedule where active='1')

--Declare @i int=100
--While @i<=@Int 
--Begin
--set @i = @i + 1
--exec ercudp_Export_Import_Error_Log_Detail @i , null
--End


