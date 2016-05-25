CREATE TABLE [dbo].[Export_Import_Schedule] (
    [ID]               INT           IDENTITY (10, 1) NOT NULL,
    [Export_Import_ID] INT           NOT NULL,
    [ClientName]       VARCHAR (50)  NULL,
    [ProcessName]      VARCHAR (100) NULL,
    [StartDate]        DATETIME      NULL,
    [EndDate]          DATETIME      NULL,
    [DayofWeek]        VARCHAR (50)  NULL,
    [DayofMonth]       VARCHAR (50)  NULL,
    [DateofMonth]      VARCHAR (50)  NULL,
    [TimeofDay]        INT           NULL,
    [TimeofDay_Stop]   INT           NULL,
    [Active]           BIT           NULL,
    [Frequency]        VARCHAR (50)  NULL,
    [FrequencyType]    VARCHAR (50)  NULL,
    [MinuteIncrement]  INT           NULL,
    [HourIncrement]    INT           NULL,
    CONSTRAINT [PK_Export_Import_Scheduler] PRIMARY KEY CLUSTERED ([ID] ASC)
);

