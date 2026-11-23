--SP_GetALL_InvDetailForRefund 156
CREATE PROCEDURE [dbo].[SP_GetALL_InvDetailForRefund]
	-- Add the parameters for the stored procedure here
    @InvoiceID INT
AS
    BEGIN
        DECLARE @DocNO VARCHAR(MAX)
        SELECT  @DocNO = InvoiceNo
        FROM    dbo.InvoiceHeaders
        WHERE   ID = @InvoiceID
        IF EXISTS ( SELECT  *
                    FROM    dbo.InvoiceHeaders
                    WHERE   ReferenceNo = @DocNO )
            BEGIN


	   

                SELECT  *
                FROM    dbo.InvoiceHeaders
                WHERE   ID = @InvoiceID
                SELECT  U.Name AS UnitName ,
                        SH.Name AS ItemName ,
                        ID.QTY - ID.ReturnQty AS QTY ,
                        ID.ID AS ID ,
                        InvoiceHeaderID ,
                        ID.ItemID ,
                        ID.UnitID ,
                        ID.UnitPrice ,
                        ID.DelievryQTY ,
                        0 AS ReturnQty ,
                        ID.AveragePrice ,
                        ID.CostPrice ,
                        ID.TaxGroupID ,
                        ID.TaxValue ,
                        ID.SerialNo ,
                        ID.ItemDiscountValue ,
                        ID.ItemDiscountType ,
                        ID.IPAddress ,
                        ID.CreatedUserID ,
                        ID.LastModUserID ,
                        ID.CreatedDate ,
                        ID.LastModDate ,
                        ID.ItemDiscountPercentage ,
                        ID.WarrentyPeriod ,
                        ID.IsPercentageForDiscount ,
                        ID.TaxCostPrice ,
                        ID.TaxForSellPrice ,
                        ID.PrintSequence
                FROM    dbo.InvoiceDetails ID
                        INNER JOIN dbo.StockItemHeaders SH ON SH.Id = ID.ItemID
                        INNER JOIN dbo.Units U ON ID.UnitID = U.Id
                WHERE   InvoiceHeaderID = @InvoiceID


                SELECT  PaymentTypeID ,
                        SUM(TenderedAmount) AS Tendered ,
                        SUM(ActualAmount) AS Actual ,
                        SUM(BalanceAmount) AS Bal
                INTO    #TMPD
                FROM    dbo.InvoicePaymentsDetails PD
                WHERE   InvoiceHeaderID IN ( SELECT ID
                                             FROM   dbo.InvoiceHeaders
                                             WHERE  ReferenceNo = @DocNO )
                GROUP BY PD.PaymentTypeID 




  
                SELECT  PD.PaymentTypeID AS ID ,
                        InvoiceHeaderID ,
                        PD.PaymentTypeID ,
                        TenderedAmount ,
                        ActualAmount -ISNULL( TMP.Actual,0) AS ActualAmount ,
                        BalanceAmount ,
                        PD.Remarks ,
                        ReferanceNumebrs ,
                        IPAddress ,
                        CreatedUserID ,
                        LastModUserID ,
                        CreatedDate ,
                        LastModDate ,
                        CreditNumber ,
                        CreditRequestID ,
                        PT.Description AS PaymentType
                FROM    dbo.InvoicePaymentsDetails PD
                        INNER JOIN dbo.PaymentTypes PT ON PT.ID = PD.PaymentTypeID
                        LEFT JOIN #TMPD TMP ON TMP.PaymentTypeID = PD.PaymentTypeID
                WHERE   InvoiceHeaderID = @InvoiceID



		--DECLARE @SumTendered DECIMAL(18,2),@SumActualAmount DECIMAL(18,2),@SumBalanceAmount DECIMAL(18,2)






		


            END 

        ELSE
            BEGIN
                SELECT  *
                FROM    dbo.InvoiceHeaders
                WHERE   ID = @InvoiceID
                SELECT  U.Name AS UnitName ,
                        SH.Name AS ItemName ,
                        ID.QTY - ID.ReturnQty AS QTY ,
                        ID.ID AS ID ,
                        InvoiceHeaderID ,
                        ID.ItemID ,
                        ID.UnitID ,
                        ID.UnitPrice ,
                        ID.DelievryQTY ,
                        0 AS ReturnQty ,
                        ID.AveragePrice ,
                        ID.CostPrice ,
                        ID.TaxGroupID ,
                        ID.TaxValue ,
                        ID.SerialNo ,
                        ID.ItemDiscountValue ,
                        ID.ItemDiscountType ,
                        ID.IPAddress ,
                        ID.CreatedUserID ,
                        ID.LastModUserID ,
                        ID.CreatedDate ,
                        ID.LastModDate ,
                        ID.ItemDiscountPercentage ,
                        ID.WarrentyPeriod ,
                        ID.IsPercentageForDiscount ,
                        ID.TaxCostPrice ,
                        ID.TaxForSellPrice ,
                        ID.PrintSequence
                FROM    dbo.InvoiceDetails ID
                        INNER JOIN dbo.StockItemHeaders SH ON SH.Id = ID.ItemID
                        INNER JOIN dbo.Units U ON ID.UnitID = U.Id
                WHERE   InvoiceHeaderID = @InvoiceID
                SELECT  * ,
                        PT.Description AS PaymentType
                FROM    dbo.InvoicePaymentsDetails PD
                        INNER JOIN dbo.PaymentTypes PT ON PT.ID = PD.PaymentTypeID
                WHERE   InvoiceHeaderID = @InvoiceID
            END
        
    END

GO

