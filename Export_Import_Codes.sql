CREATE TABLE [dbo].[Export_Import_Codes] (
    [Export_Import_ID]          INT           NOT NULL,
    [Active]                    BIT           NOT NULL,
    [ProcessTypeID]             VARCHAR (50)  NULL,
    [ClientName]                VARCHAR (255) NOT NULL,
    [Export_Import_Description] VARCHAR (255) NOT NULL,
    [ProcessID]                 VARCHAR (50)  NULL,
    CONSTRAINT [PK_Export_Import_Description] PRIMARY KEY CLUSTERED ([Export_Import_ID] ASC) WITH (FILLFACTOR = 90)
);

