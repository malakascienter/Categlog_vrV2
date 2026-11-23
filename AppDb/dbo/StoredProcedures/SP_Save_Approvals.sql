

--SP_Save_Approvals '<ArrayOfApprovalViewModel xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\"><ApprovalViewModel><IPAddress>192.168.1.203</IPAddress><CreatedUserID>1</CreatedUserID><LastModUserID>1</LastModUserID><CreatedDate>2019-01-08T08:27:46.665Z</CreatedDate><LastModDate>2019-01-08T08:27:46.665Z</LastModDate><TrasactionTypeID>7</TrasactionTypeID><TrasactionTypeName>IR/Issue Return</TrasactionTypeName><ApprovalTypeID>11</ApprovalTypeID><ApprovalTypeName>Mananger-Dec</ApprovalTypeName><UserID>7</UserID><UserName>Galilioo</UserName><LocationID>1</LocationID><PropertyID>1</PropertyID></ApprovalViewModel></ArrayOfApprovalViewModel>'
CREATE PROCEDURE [dbo].[SP_Save_Approvals] @XMLDetails AS XML
AS
DECLARE @iDocID INT;
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
        EXEC sp_xml_preparedocument @iDocID OUTPUT, @XMLDetails;
        DECLARE @TemplateId INT,
                @TemplateName VARCHAR(MAX);


        SELECT *
        INTO #TEMP1
        FROM
            OPENXML(@iDocID, 'ArrayOfApprovalViewModel/ApprovalViewModel', 2)
            WITH
            (
                TrasactionTypeID INT,
                ApprovalTypeID INT,
                UserID INT,
				IPAddress VARCHAR(MAX),
				CreatedUserID INT,
				LastModUserID INT,
				LocationID INT,
				PropertyID INT
            );


        INSERT INTO dbo.TransactionWiseApprovalTypes
        (
            TransactionApprovalID,
            TransactionID,
            PropertyID,
            LocationID,
            ApprovalTypeID,
            SeqID,
            IPAddress,
            CreatedUserID,
            LastModUserID,
            CreatedDate,
            LastModDate
        )
        SELECT 1,
               T.TrasactionTypeID,
               T.PropertyID,
               T.LocationID,
               T.ApprovalTypeID,
               1,
               '',
               1,
               1,
               GETDATE(),
               GETDATE()
        FROM #TEMP1 AS T
            LEFT JOIN TransactionWiseApprovalTypes AS TA
                ON T.TrasactionTypeID = TA.TransactionID
                   AND T.ApprovalTypeID = TA.ApprovalTypeID
        WHERE TA.TransactionID IS NULL
              AND TA.ApprovalTypeID IS NULL;
        --VALUES
        --(   0,         -- TransactionApprovalID - int
        --    0,         -- TransactionID - int
        --    0,         -- PropertyID - int
        --    0,         -- LocationID - int
        --    0,         -- ApprovalTypeID - int
        --    0,         -- SeqID - int
        --    N'',       -- IPAddress - nvarchar(max)
        --    0,         -- CreatedUserID - int
        --    0,         -- LastModUserID - int
        --    GETDATE(), -- CreatedDate - datetime
        --    GETDATE()  -- LastModDate - datetime
        --    )


        INSERT INTO dbo.UserWiseApproveLevels
        (
            PropertyId,
            LocationId,
            TransactionTypeID,
            ApproveLevelID,
            UserProfileId,
            CreatedDate,
            CreatedUser,
            ModifiedUser,
            ModifiedDate,
            IPAddress,
            CreatedUserID,
            LastModUserID,
            LastModDate
        )
        SELECT T.PropertyID,
               T.LocationID,
               T.TrasactionTypeID,
               T.ApprovalTypeID,
               T.UserID,
               GETDATE(),
               1,
               1,
               GETDATE(),
               '',
               1,
               1,
               GETDATE()
        FROM #TEMP1 AS T;
        --VALUES
        --(   0,         -- PropertyId - int
        --    0,         -- LocationId - int
        --    0,         -- TransactionTypeID - int
        --    0,         -- ApproveLevelID - int
        --    0,         -- UserProfileId - int
        --    GETDATE(), -- CreatedDate - datetime
        --    0,         -- CreatedUser - int
        --    0,         -- ModifiedUser - int
        --    GETDATE(), -- ModifiedDate - datetime
        --    N'',       -- IPAddress - nvarchar(max)
        --    0,         -- CreatedUserID - int
        --    0,         -- LastModUserID - int
        --    GETDATE()  -- LastModDate - datetime
        --    )





        COMMIT TRANSACTION;


    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRAN; --RollBack in case of Error
    END CATCH;





END;

GO

