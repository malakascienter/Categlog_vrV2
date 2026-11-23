

--SP_Invoice_SerialCheck 222,-1

CREATE PROCEDURE SP_Invoice_SerialCheck
    @InvoiceSrial VARCHAR(MAX) ,
    @result INT OUTPUT
AS
    BEGIN

        CREATE TABLE #tempinv
            (
              Id INT ,
              SerialNo NVARCHAR(MAX)
            ) 
 
        INSERT  INTO #tempinv
                ( Id ,
                  SerialNo
                )
                SELECT  Id ,
                        SerialNumber
                FROM    dbo.InvoiceSerials


        SELECT  *
        FROM    #tempinv

        DECLARE @ID INT ,
            @Serial NVARCHAR(MAX)

        WHILE ( ( SELECT    COUNT(Id)
                  FROM      #tempinv
                ) > 0 )
            BEGIN

                SELECT TOP ( 1 )
                        @ID = Id ,
                        @Serial = SerialNo
                FROM    #tempinv

                IF EXISTS ( SELECT  *
                            FROM    #tempinv
                            WHERE   SerialNo = @InvoiceSrial )
                    BEGIN

                        SET @result = 1

                        BREAK

                    END
                ELSE
                    BEGIN

                        SET @result = 0

                    END
					DELETE FROM #tempinv WHERE Id=@ID
            END



    END

GO

