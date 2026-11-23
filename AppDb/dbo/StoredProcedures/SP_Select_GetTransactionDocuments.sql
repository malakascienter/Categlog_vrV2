

--SELECT * FROM dbo.TransactionTypes

-- SP_Select_GetTransactionDocuments 1,2
CREATE PROCEDURE [dbo].[SP_Select_GetTransactionDocuments]
    @LocationId INT,
    @DocumentTypeId INT
AS
BEGIN

    IF @DocumentTypeId = 3
    BEGIN
        SELECT Id,
               DocumentNo AS text
        FROM dbo.StockTransactionHeaders
        WHERE TransactionType = 'GR'
              AND LocationID = @LocationId;
    END;

    IF @DocumentTypeId = 1
    BEGIN

        SELECT Id,
               DocumentNo AS text
        FROM dbo.RequestHeaders
        WHERE RequestType = 'RP'
              AND LocationID = @LocationId;

    END;
    IF @DocumentTypeId = 2
    BEGIN


        SELECT Id,
               PoNo AS text
        FROM dbo.PoHeaders
        WHERE LocationID = @LocationId;


    END;
    IF @DocumentTypeId = 4
    BEGIN

        SELECT Id,
               DocumentNo AS text
        FROM dbo.StockTransactionHeaders
        WHERE LocationID = @LocationId
              AND TransactionType = 'SR';

    END;
    IF @DocumentTypeId = 6
    BEGIN

        SELECT Id,
               DocumentNo AS text
        FROM dbo.StockTransactionHeaders
        WHERE LocationID = @LocationId
              AND TransactionType = 'IN';

    END;

    IF @DocumentTypeId = 5
    BEGIN

        SELECT Id,
               DocumentNo AS text
        FROM dbo.StockTransactionHeaders
        WHERE LocationID = @LocationId
              AND TransactionType = 'TO';

    END;

    IF @DocumentTypeId = 5
    BEGIN

        SELECT Id,
               DocumentNo AS text
        FROM dbo.StockTransactionHeaders
        WHERE LocationID = @LocationId
              AND TransactionType = 'TO';

    END;
    IF @DocumentTypeId = 11
    BEGIN

        SELECT Id,
               DocumentNo AS text
        FROM dbo.RequestHeaders
        WHERE LocationID = @LocationId
              AND RequestType = 'RI';



    END;
    IF @DocumentTypeId = 12
    BEGIN

        SELECT Id,
               DocumentNo AS text
        FROM dbo.StockTransactionHeaders
        WHERE LocationID = @LocationId
              AND TransactionType = 'TI';



    END;
	  IF @DocumentTypeId = 14
    BEGIN

        SELECT Id,
               DocumentNo AS text
        FROM dbo.RequestHeaders
        WHERE LocationID = @LocationId
              AND RequestType = 'RD';



    END;
	

END;

GO

