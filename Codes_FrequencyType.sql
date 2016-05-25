CREATE TABLE [dbo].[Codes_FrequencyType] (
    [FrequencyType] VARCHAR (50) NOT NULL,
    [Description]   VARCHAR (50) NULL,
    [SortOrder]     INT          NOT NULL,
    CONSTRAINT [PK_Codes_FrequencyType] PRIMARY KEY CLUSTERED ([FrequencyType] ASC)
);

