CREATE TABLE [dbo].[Franchise_Master] (
    [ID]                 INT            IDENTITY (1, 1) NOT NULL,
    [GroupofFranchiseID] INT            CONSTRAINT [DF_Franchise_Master_GroupofFranchiseID] DEFAULT ((1)) NOT NULL,
    [Name]               NVARCHAR (100) NULL,
    [IsActive]           BIT            CONSTRAINT [DF_Franchise_Master_IsActive] DEFAULT ((1)) NOT NULL,
    [BusinessName]       NVARCHAR (100) NULL,
    [Address1]           NVARCHAR (50)  NULL,
    [Address2]           NVARCHAR (100) NULL,
    [Address3]           NVARCHAR (100) NULL,
    [Telephone1]         NVARCHAR (15)  NULL,
    [Telephone2]         NVARCHAR (15)  NULL,
    [Mobile]             NVARCHAR (15)  NULL,
    [FaxNo]              NVARCHAR (15)  NULL,
    [Email]              NVARCHAR (255) NULL,
    [WebAddress]         NVARCHAR (MAX) NULL,
    [ContactPerson]      NVARCHAR (50)  NULL,
    [IPAddress]          NVARCHAR (MAX) NULL,
    [IsGLEnabled]        BIT            CONSTRAINT [DF_Franchise_Master_IsGLEnabled] DEFAULT ((1)) NOT NULL,
    [InvPropertyId]      INT            CONSTRAINT [DF_Franchise_Master_InvPropertyId] DEFAULT ((1)) NOT NULL,
    [GLCOMPCODE]         CHAR (3)       NULL,
    [MasterID]           CHAR (5)       NULL,
    [LocationREF_Code]   CHAR (3)       NULL
);


GO

