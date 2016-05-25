CREATE TABLE [dbo].[Export_Import_Error_Log] (
    [ID]                        INT           IDENTITY (10, 1) NOT NULL,
    [FileDueDate]               DATETIME      NULL,
    [Export_Import_ID]          INT           NOT NULL,
    [ProcessTypeID]             VARCHAR (50)  NULL,
    [ClientName]                VARCHAR (255) NOT NULL,
    [Export_Import_Description] VARCHAR (255) NOT NULL,
    [JobName]                   VARCHAR (255) NULL,
    [fileid]                    INT           NULL,
    [ErrorMessage]              VARCHAR (255) NOT NULL,
    CONSTRAINT [PK_ID] PRIMARY KEY CLUSTERED ([ID] ASC) WITH (FILLFACTOR = 90)
);

