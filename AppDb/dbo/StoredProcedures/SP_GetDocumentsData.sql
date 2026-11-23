--SELECT * FROM dbo.TransactionTypes
--SELECT * FROM dbo.StockTransactionHeaders
--SP_GetDocumentsData 1,1
-- EXEC [dbo].[SP_GetDocumentsData] 8434,3,'MST/GR/000130'

CREATE PROCEDURE [dbo].[SP_GetDocumentsData]
    @DocId INT,
    @DocType INT,
    @DocumentNo NVARCHAR(MAX)
AS
BEGIN

    --SELECT *  FROM dbo.StockTransactionHeaders
    --SELECT * FROM dbo.StockTransactionDetails

    SET NOCOUNT ON;

    --declare @JobHeaderID int=1


    DECLARE @Location VARCHAR(MAX),
            @PoNo NVARCHAR(MAX),
            @amount DECIMAL(18, 2),
            @Department NVARCHAR(MAX),
            @Supplier VARCHAR(MAX),
            @PoDate DATE,
            @Discount DECIMAL(18, 2),
            @NoOfItems INT,
            @ToLocation NVARCHAR(MAX),
            @DocNo VARCHAR(MAX),
            @Date DATETIME,
            @User NVARCHAR(MAX);


    IF @DocType = 3
       OR @DocType = 4
    BEGIN

        SELECT @amount = SUM(SD.Quantity * SD.UnitPrice),
               @NoOfItems = COUNT(SD.Id),
               @Discount = SUM(   CASE
                                      WHEN SD.DiscountPercentage = 0 THEN
                                          SD.DiscountValue
                                      ELSE
                                          SD.DiscountPercentage * SD.UnitPrice
                                  END
                              )
        FROM StockTransactionHeaders AS ST
            INNER JOIN dbo.StockTransactionDetails AS SD
                ON ST.Id = SD.StockTransactionHeaderID
        WHERE ST.Id = @DocId
        GROUP BY ST.Id;

        SELECT @PoNo = ST.DocumentNo,
               @Location = LS.Name,
               @Supplier = SP.Name,
               @PoDate = ST.CreatedDate
        FROM StockTransactionHeaders AS ST
            LEFT JOIN dbo.PoHeaders AS PH
                ON ST.ReferenceID = PH.Id
            INNER JOIN dbo.Locations AS LS
                ON ST.LocationID = LS.Id
            INNER JOIN dbo.Suppliers AS SP
                ON SP.ID = ST.SupplierID
        WHERE ST.Id = @DocId;


        DECLARE @HeaderTable NVARCHAR(MAX)
            = '<table cellpadding="10"  class="gridtable">
	<tr>
		<td>
			<b>Location Name</b>
		</td>
		<td>
			' + @Location + '
		</td>
	</tr>
	<tr>
		<td>
			<b>Supplier Name</b>
		</td>
		<td>
			' + @Supplier + '
		</td>
	</tr>
	<tr>
		<td>
			<b>Doc number</b>  
		</td>
			<td>
			' + @PoNo + '
		</td>
	</tr>
	<tr>
		<td>
			<b>PO Date</b>   
		</td>
		<td>
			' + CONVERT(NVARCHAR(MAX), @PoDate, 103) + '
		</td>
	</tr>
	<tr>
		<td>
			<b>No:Of Items</b>       
		</td>
		<td>
			' + CAST(@NoOfItems AS NVARCHAR) + '
		</td>
	</tr>
</table>';



    END;


    ELSE IF @DocType = 1
    BEGIN



        SELECT @DocNo = DocumentNo,
               @Date = RequestDate,
               @Location = Lc.Name,
               @User = um.UserName
        FROM dbo.RequestHeaders AS Rh
            INNER JOIN dbo.Locations AS Lc
                ON Lc.Id = Rh.LocationID
            INNER JOIN dbo.UserMasters AS um
                ON um.Id = Rh.UserProfileID
        WHERE Rh.Id = @DocId;




        SET @HeaderTable
            = N'<table cellpadding="10"  class="gridtable">
	<tr>
		<td>
			<b>Doc No:</b>
		</td>
		<td>
			' + @DocNo + N'
		</td>
	</tr>
	<tr>
		<td>
			<b>Date</b>
		</td>
		<td>
			' + CAST(@Date AS VARCHAR(MAX))
              + N'
		</td>
	</tr>
	<tr>
		<td>
			<b>Location</b>  
		</td>
			<td>
			' + @Location + N'
		</td>
	</tr>
	<tr>
		<td>
			<b>User</b>   
		</td>
		<td>
			' + @User + N'
		</td>
	</tr>
	
</table>';



    END;

    ELSE IF @DocType = 2
    BEGIN



        SELECT @PoNo = PH.PoNo,
               @Location = LS.Name,
               @PoDate = PH.DocumentDate,
			   @Supplier = SU.Name
        FROM dbo.PoHeaders AS PH
            INNER JOIN dbo.Locations AS LS
                ON PH.LocationID = LS.Id
		INNER JOIN Suppliers SU ON SU.ID = PH.SupplierID
        WHERE PH.Id = @DocId;



        SET @HeaderTable
            = N'<table cellpadding="10"  class="gridtable">
	<tr>
		<td>
			<b>Location Name</b>
		</td>
		<td>
			' + @Location + N'
		</td>
	</tr>
	<tr>
		<td>
			<b>Supplier</b>
		</td>
		<td>
			' + @Supplier + N'
		</td>
	</tr>
	<tr>
		<td>
			<b>PO number</b>  
		</td>
			<td>
			' + @PoNo + N'
		</td>
	</tr>
	<tr>
		<td>
			<b>PO Date</b>   
		</td>
		<td>
			' + CAST(@PoDate AS NVARCHAR(MAX)) + N'
		</td>
	</tr>

</table>';



    END;

    ELSE IF @DocType = 6
    BEGIN



        SELECT @PoNo = PH.PoNo,
               @Location = LS.Name,
               @PoDate = PH.DocumentDate
        FROM dbo.PoHeaders AS PH
            INNER JOIN dbo.Locations AS LS
                ON PH.LocationID = LS.Id
        WHERE PH.Id = @DocId;



        SET @HeaderTable
            = N'<table cellpadding="10"  class="gridtable">
	<tr>
		<td>
			<b>Location Name</b>
		</td>
		<td>
			' + @Location + N'
		</td>
	</tr>
	<tr>
		<td>
			<b>PO number</b>  
		</td>
			<td>
			' + @PoNo + N'
		</td>
	</tr>
	<tr>
		<td>
			<b>PO Date</b>   
		</td>
		<td>
			' + CAST(@PoDate AS NVARCHAR(MAX)) + N'
		</td>
	</tr>

</table>';



    END;

    ELSE IF @DocType = 6
    BEGIN

        SELECT @Location = L.Name,
               @Department = D.Name
        FROM dbo.StockTransactionHeaders AS sh
            INNER JOIN dbo.Locations AS L
                ON sh.LocationID = L.Id
            INNER JOIN dbo.Departments AS D
                ON sh.DepartmentID = D.Id
        WHERE sh.Id = @DocId;




        SET @HeaderTable
            = N'<table cellpadding="10"  class="gridtable">
	<tr>
		<td>
			<b>Location Name</b>
		</td>
		<td>
			' + @Location + N'
		</td>
	</tr>
	<tr>
		<td>
			<b>Department</b>  
		</td>
			<td>
			' + @Department + N'
		</td>
	</tr>
	
</table>';


    END;

    ELSE IF @DocType = 5
    BEGIN

        SELECT @Location = L.Name,
               @Date = sh.TransactionDate
        FROM dbo.StockTransactionHeaders AS sh
            INNER JOIN dbo.Locations AS L
                ON sh.LocationID = L.Id
        WHERE sh.Id = @DocId;

        SELECT @ToLocation = L.Name
        FROM dbo.StockTransactionHeaders AS sh
            INNER JOIN dbo.Locations AS L
                ON sh.TransferLocationID = L.Id
        WHERE sh.Id = @DocId;


        SET @HeaderTable
            = N'<table cellpadding="10"  class="gridtable">
	<tr>
		<td>
			<b>From  Location</b>
		</td>
		<td>
			' + @Location + N'
		</td>
	</tr>
	<tr>
		<td>
			<b>To Location</b>  
		</td>
			<td>
			' + @ToLocation + N'
		</td>
	</tr>
	<tr>
		<td>
			<b>Date</b>  
		</td>
			<td>
			' + CAST(@Date AS NVARCHAR(MAX)) + N'
		</td>
	</tr>
	
</table>';


    END;
	
	ELSE IF @DocType = 65
	BEGIN

		SELECT @Location = LO.Name,
			   @Supplier = SU.Name,
			   @PoDate = CONVERT(DATE, GA.CreatedDate)  
		FROM GRNApprovalLog GA
		INNER JOIN Locations LO ON LO.ID = GA.LocationId
		INNER JOIN Suppliers SU ON SU.ID = GA.SupplierId
		WHERE GA.id = @DocId

		SET @HeaderTable
				= N'<table cellpadding="10"  class="gridtable">
		<tr>
			<td>
				<b>Location Name</b>
			</td>
			<td>
				' + @Location + '
			</td>
	   </tr>
	   <tr>
			<td>
				<b>Supplier Name</b>
			</td>
			<td>
				' + @Supplier + '
			</td>
	  </tr>
	  <tr>
			<td>
				<b>Document number</b>  
			</td>
				<td>
				' + @DocumentNo + '
			</td>
	 </tr>
	 <tr>
			<td>
				<b>Document Date</b>  
			</td>
				<td>
				' + CONVERT(NVARCHAR(MAX), @PoDate, 103) + '
			</td>
	 </tr>
 
		</table>';
	END
	ELSE
    BEGIN

        SET @HeaderTable
            = N'<table cellpadding="10"  class="gridtable">
	<tr>
		<td>
			<b>Document No</b>
		</td>
		<td>
			' + @DocumentNo + N'
		</td>
	</tr>

	
	
</table>';


    END;


    --print @detail
    DECLARE @HtmlContent NVARCHAR(MAX) = '<TABLE  class="gridtable">
<tr>
	<td>
		' + @HeaderTable + '
	</td>
</tr>


</Table>';

    SELECT @HtmlContent;

END;

GO

