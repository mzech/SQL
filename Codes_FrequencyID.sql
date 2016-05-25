CREATE TABLE [dbo].[Codes_FrequencyID] (
    [FrequencyID] VARCHAR (50) NOT NULL,
    [Description] VARCHAR (50) NULL,
    [SortOrder]   INT          NOT NULL,
    CONSTRAINT [PK_Codes_FrequencyID] PRIMARY KEY CLUSTERED ([FrequencyID] ASC)
);

