--[dbo].[SP_RPT_PaymentTypeWiseSalesDetails] '2018-09-18','2018-09-19',1,-999
CREATE  PROCEDURE [dbo].[SP_RPT_PaymentTypeWiseSalesDetails]
    (
      @DateForm DATE ,
      @DateTo DATE ,
      @DepartmentID INT ,
      @paymentTypeID INT = -999
    )
AS
    SELECT  h.InvoiceDate ,
            h.InvoiceNo ,
            h.CustomerName ,
            h.NetTotal ,
			UM.UserName,
            pt.Description ,
            pd.ActualAmount
    FROM    InvoicePaymentsDetails pd
            INNER JOIN InvoiceHeaders h ON h.ID = pd.InvoiceHeaderID
            INNER JOIN PaymentTypes pt ON pd.PaymentTypeID = pt.ID
			INNER JOIN dbo.UserMasters UM ON UM.Id=h.CreatedUserID
    WHERE   h.InvoiceDate BETWEEN @DateForm AND @DateTo
            AND pt.ID = CASE @paymentTypeID
                          WHEN -999 THEN pt.ID
                          ELSE @paymentTypeID
                        END AND h.DepartmentID=@DepartmentID
    ORDER BY h.InvoiceDate ,
            h.InvoiceNo ,
            pt.Description

GO

