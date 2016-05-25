CREATE TABLE [dbo].[Export_Import_List] (
    [Export_Import_ID]    INT           NOT NULL,
    [ClientName]          VARCHAR (50)  NULL,
    [ProcessName]         VARCHAR (255) NULL,
    [ProcessTypeID]       VARCHAR (50)  NULL,
    [Developer]           VARCHAR (50)  NULL,
    [FrequencyID]         VARCHAR (50)  NULL,
    [FileName]            VARCHAR (100) NULL,
    [FileLocation]        VARCHAR (255) NULL,
    [EmailTo]             VARCHAR (100) NULL,
    [ScheduledInd]        BIT           NULL,
    [Active]              BIT           NULL,
    [ValidationReportInd] BIT           NULL,
    [ServerLocation]      VARCHAR (255) NULL,
    [JobName]             VARCHAR (255) NULL,
    CONSTRAINT [PK_Export_Import_Schedule] PRIMARY KEY CLUSTERED ([Export_Import_ID] ASC)
);

