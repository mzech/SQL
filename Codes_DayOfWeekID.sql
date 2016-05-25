CREATE TABLE [dbo].[Codes_DayOfWeekID] (
    [DayOfWeekID] VARCHAR (20) NOT NULL,
    [Description] VARCHAR (20) NOT NULL,
    [SortOrder]   INT          NULL,
    CONSTRAINT [PK_Codes_DayOfWeekID] PRIMARY KEY CLUSTERED ([DayOfWeekID] ASC)
);

