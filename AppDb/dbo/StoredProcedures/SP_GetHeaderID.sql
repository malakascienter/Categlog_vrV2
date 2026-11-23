
--SP_GetHeaderID 'MSP/GR/000671',3
--SP_GetHeaderID 'IN000732',9              
CREATE PROCEDURE SP_GetHeaderID
    @DocNo VARCHAR(MAX) ,
    @TranType INT
AS
    BEGIN
        IF ( @TranType = 9 )
            BEGIN
                SELECT  ID
                FROM    dbo.InvoiceHeaders
                WHERE   InvoiceNo = @DocNo

            END
        ELSE
            IF ( @TranType = 3 )
                BEGIN

                    SELECT  Id
                    FROM    dbo.StockTransactionHeaders
                    WHERE   DocumentNo = @DocNo

                END 
    END

GO

