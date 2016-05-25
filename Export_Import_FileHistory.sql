CREATE TABLE [dbo].[Export_Import_FileHistory] (
    [FileID]                   INT           IDENTITY (1000, 1) NOT NULL,
    [FileSendReceiveDate]      DATETIME      NULL,
    [Export_Import_ID]         INT           NOT NULL,
    [FileName]                 VARCHAR (50)  NULL,
    [FileTypeCode]             VARCHAR (12)  NOT NULL,
    [FileLocation]             VARCHAR (250) NULL,
    [StartDateTime]            DATETIME      NULL,
    [CompleteDatetime]         DATETIME      NULL,
    [FilePostedDate]           DATETIME      NULL,
    [FileReceiptReceivedDate]  DATETIME      NULL,
    [ValidationReportDoneDate] DATETIME      NULL,
    [ValidationReportLocation] VARCHAR (250) NULL,
    CONSTRAINT [PK_Export_Import_FileHistory] PRIMARY KEY CLUSTERED ([FileID] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_Export_Import_FileHistory_ExportDestinationCodes] FOREIGN KEY ([Export_Import_ID]) REFERENCES [dbo].[Export_Import_Codes] ([Export_Import_ID])
);

