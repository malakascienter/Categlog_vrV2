-- =============================================
-- Author:		Isuru Pramodya
-- Modify By:	Nivesh
-- Modified date:2024-11-01
-- Create date: 2024-09-27
-- Description:	Sending TransactionWise Email

-- [dbo].[SendTransactionWiseEmailS] 'PO',7300,1,1,'C'


-- =============================================
CREATE PROCEDURE [dbo].[SendTransactionWiseEmailS]
	@TransactionType CHAR(2),
	@HeaderID INT,
	@LocationID INT,
	@PropertyID INT,
	@Operation CHAR(2)
	AS
BEGIN

	SET NOCOUNT ON;

	--Added by Isuru 2025-02-26
	INSERT INTO SendTransactionWiseEmailS_Log(TransactionType, HeaderID, LocationID, PropertyID, Operation, SysDate)
	SELECT @TransactionType,@HeaderID,@LocationID,@PropertyID,@Operation,GETDATE()
	--End

	IF OBJECT_ID('tempdb..#TempEmail') IS NOT NULL
	DROP TABLE #TempEmail

	IF OBJECT_ID('tempdb..#TempStockSpotHeader') IS NOT NULL
	DROP TABLE #TempStockSpotHeader

		IF OBJECT_ID('tempdb..#TempStockItemDetails') IS NOT NULL
	DROP TABLE #TempStockItemDetails

	IF OBJECT_ID('tempdb..#AccessibleMenuItems') IS NOT NULL
	DROP TABLE #AccessibleMenuItems

	IF OBJECT_ID('tempdb..#userwiseEmail') IS NOT NULL
	DROP TABLE #userwiseEmail

	IF OBJECT_ID('tempdb..#AccessibleMenuItems2') IS NOT NULL
	DROP TABLE #AccessibleMenuItems2

	IF OBJECT_ID('tempdb..#userwiseEmail2') IS NOT NULL
	DROP TABLE #userwiseEmail2

		
	CREATE TABLE #TempStockSpotHeader(
		StockItemCode VARCHAR(MAX),
		Name VARCHAR(MAX),
		QuantityInHand DECIMAL(18,2),
		PhysicalQty DECIMAL(18,2)
	)


	CREATE TABLE #TempStockItemDetails(
		StockItemCode VARCHAR(MAX),
		Name VARCHAR(MAX),
		Qty DECIMAL(18,2)
	)
	CREATE TABLE #TempEmail(ID INT IDENTITY,UserID INT, UserName VARCHAR(MAX),Email VARCHAR(MAX))

	DECLARE @IsAutoTransferIn BIT,@ModuleId	INT = 4


	SELECT @IsAutoTransferIn = ISNULL(IsAutoTransferIn,0)
	FROM Companies
	WHERE CompanyID= @PropertyID


	DECLARE @Email NVARCHAR(MAX),@EmailBody NVARCHAR(MAX), @CompanyName VARCHAR(200), @LocationName VARCHAR(MAX), @RequestedUser VARCHAR(MAX)
	,@TransactionTypeName VARCHAR(MAX), @DocumentNo VARCHAR(MAX)
	DECLARE @NewEmail VARCHAR(MAX),@NewApprovalUserID INT,@NewMailSubject VARCHAR(MAX)
	
	SELECT @TransactionTypeName = Name
	FROM TransactionTypes
	WHERE Code = @TransactionType

	IF EXISTS (SELECT 1 FROM TransactionTypes WHERE CODE  = @TransactionType AND IsMailNotification =1)
	BEGIN
		IF(@Operation ='C')
		BEGIN
			IF(@TransactionType = 'RT') -- Email Send for Transfer Request
			BEGIN

				INSERT INTO #TempEmail(UserID, UserName,Email)
				SELECT CU.Id UserID,cu.UserName,CU.Email
				FROM RequestHeaders RH
				INNER JOIN TransactionWiseEmails TE ON TE.TransactionType = RH.RequestType
				INNER JOIN CentralUsers CU ON CU.Id = TE.UserID
				WHERE RH.Id  =@HeaderID AND RequestType = @TransactionType
				AND TE.IsActive=1 AND TE.PropertyID = @PropertyID AND TE.LocationID = @LocationID
				AND TE.TransactionType= @TransactionType AND IsApproved=1 AND RH.SendMail = 0

				INSERT INTO  #TempStockItemDetails
				SELECT SH.StockItemCode,SH.Name,RD.ApprovedQuantity Qty
				FROM RequestHeaders RH
				INNER JOIN RequestDetails RD ON RH.Id = RD.RequestHeaderID
				INNER JOIN StockItemHeaders SH ON SH.Id = RD.StockItemID
				WHERE RH.Id = @HeaderID

			

				SELECT @DocumentNo= DocumentNo,@RequestedUser= CU.UserName,@LocationName = LO.Name, @CompanyName = CO.Name 
				FROM RequestHeaders RH
				INNER JOIN Locations LO ON RH.LocationID = LO.Id
				INNER JOIN CentralUsers CU ON CU.Id = RH.UserProfileID
				INNER JOIN Companies CO ON CO.CompanyID = RH.PropertyID
				WHERE RH.Id = @HeaderID		

				SET @EmailBody = '<html>
				<body>
				<h2>Below transaction has been approved</h2>
				<p>• Transaction type : '+@TransactionTypeName+' </p>
				<p>• Document Number : '+@DocumentNo+' </p>
				<p>• Company Name : '+@CompanyName+' </p>
				<p>• Location Name : '+@LocationName+' </p>
				<p>• Requested User : '+@RequestedUser+' </p>
								
							  <table border = 1>
							  <thead>
								  <th style="width: 20%;">Item Code</th>
								  <th style="width: 20%;">Item Name</th>
								  <th style="width: 20%;">Approved Quantity</th>
							  </thead>
							  <tbody>' +
								(
								SELECT STRING_AGG(
									'<tr><td>' + CAST(StockItemCode AS VARCHAR(MAX)) + 
									'</td><td>' + CAST(Name AS VARCHAR(MAX)) + 
									'</td><td>' + CAST(Qty AS VARCHAR(MAX)) + 
									'</td></tr>', 
									''
								) AS [text()]
								FROM #TempStockItemDetails
							) +
							'</tbody>
							  </table>
							  <br><br>
							  <p style="font-size:12px;color:gray;"><small>This email is auto generated, please do not respond.</small></p>
							  </body>
							  </html>';

			END

			IF(@TransactionType ='TO') -- Email Send for Transfer out
			BEGIN

			IF(@IsAutoTransferIn = 0)
			BEGIN
				INSERT INTO #TempEmail(UserID, UserName,Email)
				SELECT cu.Id UserID,cu.UserName,cu.Email
				FROM StockTransactionHeaders SH
				INNER JOIN TransactionWiseEmails TE ON TE.TransactionType = SH.TransactionType
				INNER JOIN CentralUsers CU ON CU.Id = TE.UserID
				WHERE SH.ID = @HeaderID AND SH.TransactionType = @TransactionType
				AND TE.IsActive=1 AND TE.PropertyID = @PropertyID AND TE.LocationID = @LocationID
				AND TE.TransactionType= @TransactionType  AND SH.SendMail = 0

				INSERT INTO  #TempStockItemDetails
				SELECT SH.StockItemCode,SH.Name,RD.Quantity Qty
				FROM StockTransactionHeaders RH
				INNER JOIN StockTransactionDetails RD ON RH.Id = RD.StockTransactionHeaderID
				INNER JOIN StockItemHeaders SH ON SH.Id = RD.StockItemID
				WHERE RH.Id = @HeaderID

				SELECT @DocumentNo= SH.DocumentNo,@RequestedUser= CU.UserName,@LocationName = LO.Name, @CompanyName = CO.Name 
				FROM StockTransactionHeaders SH
				INNER JOIN Locations LO ON SH.TransferLocationID = lo.Id
				INNER JOIN CentralUsers CU ON CU.Id = SH.UserProfileID
				INNER JOIN Companies CO ON CO.CompanyID = SH.PropertyID
				WHERE SH.Id =@HeaderID

			
				SET @EmailBody = '<html>
				<body>
				<h2>Below transaction has been approved</h2>
				<p>• Transaction type : '+@TransactionTypeName+' </p>
				<p>• Document Number : '+@DocumentNo+' </p>
				<p>• Company Name : '+@CompanyName+' </p>
				<p>• Location Name : '+@LocationName+' </p>
				<p>• Requested User : '+@RequestedUser+' </p>
								
							  <table border = 1>
							  <thead>
								  <th style="width: 20%;">Item Code</th>
								  <th style="width: 20%;">Item Name</th>
								  <th style="width: 20%;">Approved Quantity</th>
							  </thead>
							  <tbody>' +
								(
								SELECT STRING_AGG(
									'<tr><td>' + CAST(StockItemCode AS VARCHAR(MAX)) + 
									'</td><td>' + CAST(Name AS VARCHAR(MAX)) + 
									'</td><td>' + CAST(Qty AS VARCHAR(20)) + 
									'</td></tr>', 
									''
								) AS [text()]
								FROM #TempStockItemDetails
							) +
							'</tbody>
							  </table>
							  <br><br>
							  <p style="font-size:12px;color:gray;"><small>This email is auto generated, please do not respond.</small></p>
							  </body>
							  </html>';

				--SET @EmailBody = '<html><body><p>Below transaction has been approved</p>
				--			  <table border = 1>
				--			  <thead>
				--				  <th  style="width: 20%" >Transaction type</th>
				--				  <th  style="width: 20%" >Document Number</th>
				--				  <th  style="width: 20%" >Company Name</th>
				--				  <th  style="width: 20%" >Location Name</th>
				--				  <th  style="width: 20%" >Requested User</th>
				--			  </thead>
				--			  <tbody >
				--				<tr>
				--				 <td  style="width: 20%" >'+@TransactionTypeName+'</td>
				--				 <td  style="width: 20%" >'+@DocumentNo+'</td>
				--				 <td  style="width: 20%" >'+@CompanyName+'</td>
				--				 <td  style="width: 20%" >'+@LocationName+'</td>
				--				 <td  style="width: 20%" >'+@RequestedUser+'</td>
			 --                   </tr>
				--			  </tbody>
				--			  </table></html></body>
				--			  <br><br><p style="font-size:12px;color:gray;"><small >This email is auto generated, please do not respond.</small></p>
				--			  '


		
		   END
			END


			IF(@TransactionType = 'CR') -- Email Send for Commi Request 
			BEGIN

			IF EXISTS(SELECT 1 FROM TransactionWiseEmails WHERE TransactionType = 'CR' AND LocationID = @LocationID AND PropertyID = @PropertyID)
			BEGIN
				INSERT INTO #TempEmail(UserID, UserName,Email)
				SELECT CU.Id UserID,cu.UserName,CU.Email
				FROM CommiRequestHeader CH
				INNER JOIN CentralUsers CU ON CU.Id = CH.UserID
				WHERE CH.ID=@HeaderID


				SELECT @DocumentNo= DocumentNo,@RequestedUser= CU.UserName,@LocationName = LO.Name, @CompanyName = CO.Name 
				FROM RequestHeaders RH
				INNER JOIN Locations LO ON RH.LocationID = LO.Id
				INNER JOIN CentralUsers CU ON CU.Id = RH.UserProfileID
				INNER JOIN Companies CO ON CO.CompanyID = RH.PropertyID
				WHERE RH.Id = @HeaderID		

				SELECT @DocumentNo= CH.TxnNo,@RequestedUser= CU.UserName,@LocationName = LO.Name, @CompanyName = CO.Name 
				FROM CommiRequestHeader CH
				INNER JOIN Locations LO ON LO.Id = CH.ProductionLocationID
				INNER JOIN CentralUsers CU ON CU.Id = CH.UserID
				INNER JOIN Companies CO ON CO.CompanyID = CH.PropertyID
				WHERE CH.Id = @HeaderID		


				SET @EmailBody = '<html><body><p>Below transaction has been approved</p>
							  <table border = 1>
							  <thead>
								  <th  style="width: 20%" >Transaction type</th>
								  <th  style="width: 20%" >Document Number</th>
								  <th  style="width: 20%" >Company Name</th>
								  <th  style="width: 20%" >Location Name</th>
								  <th  style="width: 20%" >Requested User</th>
							  </thead>
							  <tbody >
								<tr>
								 <td  style="width: 20%" >'+@TransactionTypeName+'</td>
								 <td  style="width: 20%" >'+@DocumentNo+'</td>
								 <td  style="width: 20%" >'+@CompanyName+'</td>
								 <td  style="width: 20%" >'+@LocationName+'</td>
								 <td  style="width: 20%" >'+@RequestedUser+'</td>
								</tr>
							  </tbody>
							  </table></html></body>
							  <br><br><p style="font-size:12px;color:gray;"><small >This email is auto generated, please do not respond.</small></p>
							  '
			END
			END

			IF(@TransactionType = 'RP')  -- Email Send for purchase Request 
			BEGIN
				DECLARE @PRRemark VARCHAR(MAX)
				INSERT INTO #TempEmail(UserID, UserName,Email)
				SELECT CU.Id UserID,cu.UserName,CU.Email
				FROM RequestHeaders RH
				INNER JOIN TransactionWiseEmails TE ON TE.TransactionType = RH.RequestType
				INNER JOIN CentralUsers CU ON CU.Id = TE.UserID
				WHERE RH.Id  =@HeaderID AND RequestType = @TransactionType
				AND TE.IsActive=1 AND TE.PropertyID = @PropertyID AND TE.LocationID = @LocationID
				AND TE.TransactionType= @TransactionType AND IsApproved=1 AND RH.SendMail = 0

			
				INSERT INTO  #TempStockItemDetails
				SELECT SH.StockItemCode,SH.Name,RD.ApprovedQuantity Qty
				FROM RequestHeaders RH
				INNER JOIN RequestDetails RD ON RH.Id = RD.RequestHeaderID
				INNER JOIN StockItemHeaders SH ON SH.Id = RD.StockItemID
				WHERE RH.Id = @HeaderID


				SELECT @DocumentNo= DocumentNo,@RequestedUser= CU.UserName,@LocationName = LO.Name, @CompanyName = CO.Name,@PRRemark = RH.Remarks
				FROM RequestHeaders RH
				INNER JOIN Locations LO ON RH.LocationID = LO.Id
				INNER JOIN CentralUsers CU ON CU.Id = RH.UserProfileID
				INNER JOIN Companies CO ON CO.CompanyID = RH.PropertyID
				WHERE RH.Id = @HeaderID		

				SET @EmailBody = '<html>
				<body>
				<h2>Below transaction has been approved</h2>
				<p>• Transaction type : '+@TransactionTypeName+' </p>
				<p>• Document Number : '+@DocumentNo+' </p>
				<p>• Company Name : '+@CompanyName+' </p>
				<p>• Location Name : '+@LocationName+' </p>
				<p>• Remark : '+ISNULL(@PRRemark,'')+' </p>
				<p>• Requested User : '+@RequestedUser+' </p>
								
							  <table border = 1>
							  <thead>
								  <th style="width: 20%;">Item Code</th>
								  <th style="width: 20%;">Item Name</th>
								  <th style="width: 20%;">Approved Quantity</th>
							  </thead>
							  <tbody>' +
								(
								SELECT STRING_AGG(
									'<tr><td>' + CAST(StockItemCode AS VARCHAR(MAX)) + 
									'</td><td>' + CAST(Name AS VARCHAR(MAX)) + 
									'</td><td>' + CAST(Qty AS VARCHAR(MAX)) + 
									'</td></tr>', 
									''
								) AS [text()]
								FROM #TempStockItemDetails
							) +
							'</tbody>
							  </table>
							  <br><br>
							  <p style="font-size:12px;color:gray;"><small>This email is auto generated, please do not respond.</small></p>
							  </body>
							  </html>';

SELECT @EmailBody
				--SET @EmailBody = '<html><body><p>Below transaction has been approved</p>
				--			  <table border = 1>
				--			  <thead>
				--				  <th  style="width: 20%" >Transaction type</th>
				--				  <th  style="width: 20%" >Document Number</th>
				--				  <th  style="width: 20%" >Company Name</th>
				--				  <th  style="width: 20%" >Location Name</th>
				--				  <th  style="width: 20%" >Requested User</th>
				--			  </thead>
				--			  <tbody >
				--				<tr>
				--				 <td  style="width: 20%" >'+@TransactionTypeName+'</td>
				--				 <td  style="width: 20%" >'+@DocumentNo+'</td>
				--				 <td  style="width: 20%" >'+@CompanyName+'</td>
				--				 <td  style="width: 20%" >'+@LocationName+'</td>
				--				 <td  style="width: 20%" >'+@RequestedUser+'</td>
			 --                   </tr>
				--			  </tbody>
				--			  </table></html></body>
				--			  <br><br><p style="font-size:12px;color:gray;"><small >This email is auto generated, please do not respond.</small></p>
				--			  '

			END

			IF(@TransactionType = 'RI')  -- Email Send for Issue  Request 
			BEGIN
				DECLARE @IRRemark VARCHAR(MAX)
				INSERT INTO #TempEmail(UserID, UserName,Email)
				SELECT CU.Id UserID,cu.UserName,CU.Email
				FROM RequestHeaders RH
				INNER JOIN TransactionWiseEmails TE ON TE.TransactionType = RH.RequestType
				INNER JOIN CentralUsers CU ON CU.Id = TE.UserID
				WHERE RH.Id  =@HeaderID AND RequestType = @TransactionType
				AND TE.IsActive=1 AND TE.PropertyID = @PropertyID AND TE.LocationID = @LocationID
				AND TE.TransactionType= @TransactionType AND IsApproved=1 AND RH.SendMail = 0

			
				INSERT INTO  #TempStockItemDetails
				SELECT SH.StockItemCode,SH.Name,RD.ApprovedQuantity Qty
				FROM RequestHeaders RH
				INNER JOIN RequestDetails RD ON RH.Id = RD.RequestHeaderID
				INNER JOIN StockItemHeaders SH ON SH.Id = RD.StockItemID
				WHERE RH.Id = @HeaderID


				SELECT @DocumentNo= DocumentNo,@RequestedUser= CU.UserName,@LocationName = LO.Name, @CompanyName = CO.Name,@IRRemark = RH.Remarks
				FROM RequestHeaders RH
				INNER JOIN Locations LO ON RH.LocationID = LO.Id
				INNER JOIN CentralUsers CU ON CU.Id = RH.UserProfileID
				INNER JOIN Companies CO ON CO.CompanyID = RH.PropertyID
				WHERE RH.Id = @HeaderID		

				SET @EmailBody = '<html>
				<body>
				<h2>Below transaction has been approved</h2>
				<p>• Transaction type : '+@TransactionTypeName+' </p>
				<p>• Document Number : '+@DocumentNo+' </p>
				<p>• Company Name : '+@CompanyName+' </p>
				<p>• Location Name : '+@LocationName+' </p>
				<p>• Remark : '+ISNULL(@IRRemark,'')+' </p>
				<p>• Requested User : '+@RequestedUser+' </p>
								
							  <table border = 1>
							  <thead>
								  <th style="width: 20%;">Item Code</th>
								  <th style="width: 20%;">Item Name</th>
								  <th style="width: 20%;">Approved Quantity</th>
							  </thead>
							  <tbody>' +
								(
								SELECT STRING_AGG(
									'<tr><td>' + CAST(StockItemCode AS VARCHAR(MAX)) + 
									'</td><td>' + CAST(Name AS VARCHAR(MAX)) + 
									'</td><td>' + CAST(Qty AS VARCHAR(MAX)) + 
									'</td></tr>', 
									''
								) AS [text()]
								FROM #TempStockItemDetails
							) +
							'</tbody>
							  </table>
							  <br><br>
							  <p style="font-size:12px;color:gray;"><small>This email is auto generated, please do not respond.</small></p>
							  </body>
							  </html>';


				
				SELECT @EmailBody EmailBody
			END

			IF(@TransactionType = 'PO') -- Email Send for purchase Order 
			BEGIN
				DECLARE @PORemark VARCHAR(MAX),@POSubmitUserID INT

				INSERT INTO #TempEmail(UserID, UserName,Email)
				SELECT CU.Id UserID,cu.UserName,CU.Email
				FROM PoHeaders PH
				INNER JOIN TransactionWiseEmails TE ON TE.TransactionType = 'PO'
				INNER JOIN CentralUsers CU ON CU.Id = TE.UserID
				WHERE PH.Id  =@HeaderID AND TE.IsActive=1 AND TE.PropertyID = @PropertyID AND TE.LocationID = @LocationID
				AND TE.TransactionType= @TransactionType AND IsApproved=1 


				INSERT INTO  #TempStockItemDetails
				SELECT SH.StockItemCode,SH.Name,RD.ApprovedQuantity Qty
				FROM PoHeaders RH
				INNER JOIN PoDetails RD ON RH.Id = RD.PoHeaderID
				INNER JOIN StockItemHeaders SH ON SH.Id = RD.StockItemID
				WHERE RH.Id = @HeaderID

			
				SELECT  @DocumentNo= PoNo,@RequestedUser= CU.UserName,@LocationName = LO.Name, @CompanyName = CO.Name,@PORemark = PH.Remarks 
				,@POSubmitUserID = ph.UserProfileID
				FROM PoHeaders PH
				INNER JOIN Locations LO ON PH.LocationID = LO.Id
				INNER JOIN CentralUsers CU ON CU.Id = PH.UserProfileID
				INNER JOIN Companies CO ON CO.CompanyID = PH.PropertyID
				WHERE PH.Id=@HeaderID

				--Sending Email copy to PO submitted User also
				INSERT INTO #TempEmail(UserID, UserName,Email)
				SELECT CU.ID userid,cu.UserName,CU.Email email
				FROM CentralUsers CU
				INNER JOIN PoHeaders PH ON PH.UserProfileID = CU.ID
				WHERE PH.ID = @HeaderID
				AND PH.IsApproved=1
				--End

				SET @EmailBody = '<html>
				<body>
				<h2>Below transaction has been approved</h2>
				<p>• Transaction type : '+@TransactionTypeName+' </p>
				<p>• Document Number : '+@DocumentNo+' </p>
				<p>• Company Name : '+@CompanyName+' </p>
				<p>• Location Name : '+@LocationName+' </p>
				<p>• Remark : '+ISNULL(@PORemark,'')+' </p>
				<p>• Requested User : '+@RequestedUser+' </p>
								
							  <table border = 1>
							  <thead>
								  <th style="width: 20%;">Item Code</th>
								  <th style="width: 20%;">Item Name</th>
								  <th style="width: 20%;">Approved Quantity</th>
							  </thead>
							  <tbody>' +
								(
								SELECT STRING_AGG(
									'<tr><td>' + CAST(StockItemCode AS VARCHAR(MAX)) + 
									'</td><td>' + CAST(Name AS VARCHAR(MAX)) + 
									'</td><td>' + CAST(Qty AS VARCHAR(MAX)) + 
									'</td></tr>', 
									''
								) AS [text()]
								FROM #TempStockItemDetails
							) +
							'</tbody>
							  </table>
							  <br><br>
							  <p style="font-size:12px;color:gray;"><small>This email is auto generated, please do not respond.</small></p>
							  </body>
							  </html>';


				--SET @EmailBody = '<html><body><p>Below transaction has been approved</p>
				--			  <table border = 1>
				--			  <thead>
				--				  <th  style="width: 20%" >Transaction type</th>
				--				  <th  style="width: 20%" >Document Number</th>
				--				  <th  style="width: 20%" >Company Name</th>
				--				  <th  style="width: 20%" >Location Name</th>
				--				  <th  style="width: 20%" >Requested User</th>
				--			  </thead>
				--			  <tbody >
				--				<tr>
				--				 <td  style="width: 20%" >'+@TransactionTypeName+'</td>
				--				 <td  style="width: 20%" >'+@DocumentNo+'</td>
				--				 <td  style="width: 20%" >'+@CompanyName+'</td>
				--				 <td  style="width: 20%" >'+@LocationName+'</td>
				--				 <td  style="width: 20%" >'+@RequestedUser+'</td>
			 --                   </tr>
				--			  </tbody>
				--			  </table></html></body>
				--			   <br><br><p style="font-size:12px;color:gray;"><small >This email is auto generated, please do not respond.</small></p>
				--			  '

			END

			IF(@TransactionType = 'SS') -- Email Send for Stock Spot Check
			BEGIN
				INSERT INTO #TempStockSpotHeader
				SELECT SH.StockItemCode,SH.Name,ROUND(SD.QuantityInHand,2) QuantityInHand,ROUND(SD.PhysicalQty,2) PhysicalQty 
					FROM StockSpotCheckDetail SD
					INNER JOIN StockItemHeaders SH ON SH.Id = SD.StockItemID
					WHERE SD.StockSpotHeaderID = @HeaderID

				SELECT  @DocumentNo= PH.DocNo,@RequestedUser= CU.UserName,@LocationName = LO.Name, @CompanyName = CO.Name 
				FROM StockSpotCheckHeader PH
				INNER JOIN Locations LO ON PH.LocationID = LO.Id
				INNER JOIN CentralUsers CU ON CU.Id = PH.UserID
				INNER JOIN Companies CO ON CO.CompanyID = PH.PropertyID
				WHERE PH.Id=@HeaderID

				SET @EmailBody = '<p style="font-size:12px;color:gray;">
					Below transaction has been approved
					<br><br>
				</p>' +
				'<table border="1" style="border-collapse: collapse; width: 100%;">' +
				'<thead>' +
				'<tr><th>Code</th><th>Name</th><th>System Qty In Hand</th><th>Physical Quantity</th></tr>' +
				'</thead>' +
				'<tbody>' +
				(
					SELECT STRING_AGG(
						'<tr><td>' + CAST(StockItemCode AS VARCHAR(MAX)) + 
						'</td><td>' + CAST(Name AS VARCHAR(MAX)) + 
						'</td><td>' + CAST(QuantityInHand AS VARCHAR(20)) + 
						 '</td><td>' + CAST(PhysicalQty AS VARCHAR(20)) + 
						'</td></tr>', 
						''
					) AS [text()]
					FROM #TempStockSpotHeader
				) +
				'</tbody>' +
				'</table>';	
			
							SELECT X.*
				INTO #AccessibleMenuItems3
				FROM 
				(
					select A.Id AS MenuItemId ,cu.UserId
					from CentralAccessDB..Admin_Nav_AreasWisePages A
					INNER JOIN  CentralAccessDB..[Central_UserRoleWiseMenuItems] B ON B.MenuItemId = A.Id and b.MenuItemId in (2535,2536)
					inner join CentralAccessDB..Central_UserWiseUserRoles cu on cu.UserRoleId = b.UserRoleId 
					where 
					A.ModuleId = @ModuleId
					UNION
					SELECT A.MenuItemId, A.UserId
					FROM CentralAccessDB..[Central_UserWiseIndividualMenuItems] A
					WHERE 
					A.ModuleId = @ModuleId	and a.MenuItemId in (2535,2536)
					AND A.PropertyId=@PropertyId

				) AS X

						SELECT  d.userid,D.MenuItemId,b.email,
						(CASE ISNULL(D.MenuItemId,0) WHEN 0 THEN 0 ELSE 1 END) AS 'Access'
						into #userwiseEmail3
						FROM CentralAccessDB..Admin_Nav_AreasWisePages C
						inner JOIN #AccessibleMenuItems3 D ON C.Id = D.MenuItemId
						inner join CentralAccessDB..Central_Users B ON d.UserId = B.Id
						WHERE C.ModuleId = 4
						 AND C.IsActive=1 and D.MenuItemId in (2535,2536)

						  --select userid,email from #userwiseEmail where MenuItemId = 2536
					SELECT @NewEmail = STRING_AGG(email, ';')  FROM #userwiseEmail3 where MenuItemId in (2535,2536)

					INSERT INTO #TempEmail (UserID , UserName ,Email)
					VALUES(0,'',@NewEmail)

				
			END

			
			IF(@TransactionType = 'SC') -- Email send for Supplier Creation
			BEGIN
			
			DECLARE @SupplierName VARCHAR(MAX),@Address1 VARCHAR(MAX),@SupEmail VARCHAR(MAX),@Telephone1 VARCHAR(20),@SupRequestedUser VARCHAR(MAX),
			@VatNo VARCHAR(MAX),@CreditorType VARCHAR(MAX),@CreditPeriod INT,@CreditLimit DECIMAL(18,6)


				SELECT @SupplierName= ISNULL(SR.Name,'') ,@CompanyName =CO.Name,@Address1 =ISNULL(SR.Address1,''),@SupEmail = ISNULL(SR.Email,'N/A'),
				@Telephone1 = ISNULL(SR.Telephone1,''),@SupRequestedUser = CU.UserName,@VatNo = ISNULL(SR.VatNo,''),@CreditorType = ISNULL(AP.Name,'') 
				,@CreditPeriod = ISNULL(SR.CreditPeriod,0),@CreditLimit = ISNULL(SR.CreditLimit,0)
				--INTO #TempSupplier
				FROM SuppliersRequest SR WITH(NOLOCK)
				INNER JOIN Companies CO WITH(NOLOCK) ON CO.COMPANYID = SR.PROPERTYID
				INNER JOIN CENTRALUSERS CU WITH(NOLOCK) ON CU.ID = SR.CreatedUserID
				INNER JOIN CurrencyMasters CR WITH(NOLOCK) ON CR.ID =SR.CurrencyID
				INNER JOIN [eFinancials_Accounting]..Destinity_AP_CreditorTypes AP WITH(NOLOCK) ON AP.ID = SR.CreditorTypeID
				WHERE SR.ID=@HeaderID

				SELECT  @SupplierName SupplierName,@CompanyName CompanyName,@Address1 Address1,@SupEmail SupEmail,@Telephone1 Telephone1,@SupRequestedUser SupRequestedUser,
				@VatNo VatNo,@CreditorType CreditorType,@CreditPeriod CreditPeriod,@CreditLimit CreditLimit
				

				SELECT @EmailBody EmailBody

				SET @EmailBody = 
				'<html>
				<body>
				<h2>Supplier Creation</h2>
				<p>The following supplier creation request has been <strong>submitted</strong> and requires your final approval.</p>

				<p><strong>Transaction Type:</strong> Supplier Creation </p>
				<p><strong>Company:</strong> ' + @CompanyName + '</p>
				<p><strong>Requested By:</strong> ' + @SupRequestedUser + '</p>

				<h3>Supplier Details</h3>
				<table border="1" cellspacing="0" cellpadding="5" style="border-collapse: collapse; width: 100%;">
				<thead>
				<tr style="background-color: #f2f2f2;">
				<th>Supplier Name</th>
				<th>Address</th>
				<th>Credit Limit</th>
				<th>Credit Period</th>
				<th>VAT No</th>
				<th>Creditor Type</th>
				</tr>
				</thead>
				<tbody>
				<tr>
				<td>' + @SupplierName + '</td>
				<td>' + @Address1 + '</td>
				<td>' + CAST(@CreditLimit AS VARCHAR(MAX))  + '</td>
				<td>' + CAST(@CreditPeriod AS VARCHAR(MAX)) + '</td>
				<td>' + CAST(@VatNo AS VARCHAR(MAX))   + '</td>
				<td>' + CAST(@CreditorType AS VARCHAR(MAX))  + '</td>
				</tr>
				</tbody>
				</table>

				<br><br>
				<p style="font-size:12px; color:gray;">
				<small>This email is auto-generated. Please do not reply.</small>
				</p>
				</body>
				</html>'
				
				SELECT @EmailBody EmailBody

				SELECT X.*
				INTO #SupplierPageAccessList
				FROM 
				(
					select A.Id AS MenuItemId ,cu.UserId
					from CentralAccessDB..Admin_Nav_AreasWisePages A
					INNER JOIN  CentralAccessDB..[Central_UserRoleWiseMenuItems] B ON B.MenuItemId = A.Id and b.MenuItemId in (130)
					inner join CentralAccessDB..Central_UserWiseUserRoles cu on cu.UserRoleId = b.UserRoleId 
					inner join CentralAccessDB..Central_UserWiseProperties CP ON CP.UserId = CU.UserId AND CP.PropertyId=@PropertyId
					where 
					A.ModuleId = @ModuleId
					UNION
					SELECT A.MenuItemId, A.UserId
					FROM CentralAccessDB..[Central_UserWiseIndividualMenuItems] A
					WHERE 
					A.ModuleId = @ModuleId	and a.MenuItemId in (130)
					AND A.PropertyId=@PropertyId

				) AS X

						SELECT  d.userid,D.MenuItemId,b.email,
						(CASE ISNULL(D.MenuItemId,0) WHEN 0 THEN 0 ELSE 1 END) AS 'Access'
						into #userwiseEmail4
						FROM CentralAccessDB..Admin_Nav_AreasWisePages C
						inner JOIN #SupplierPageAccessList D ON C.Id = D.MenuItemId
						inner join CentralAccessDB..Central_Users B ON d.UserId = B.Id
						WHERE C.ModuleId = 4
						 AND C.IsActive=1 and D.MenuItemId in (130)

						  --select userid,email from #userwiseEmail where MenuItemId = 2536
					SELECT @NewEmail = STRING_AGG(email, ';') FROM (SELECT DISTINCT email FROM #userwiseEmail4 WHERE MenuItemId IN (130)) AS DistinctEmails;

					INSERT INTO #TempEmail (UserID , UserName ,Email)
					VALUES(0,'',@NewEmail)


					

		
			END


			
			IF(@TransactionType = 'IC')-- Email send for Item Creation
			BEGIN

				DECLARE 
				@ItemCode VARCHAR(100),
				@ItemDescription VARCHAR(MAX),
				@Remarks VARCHAR(MAX),
				@CategoryName VARCHAR(200),
				@SubCatName VARCHAR(200),
				@SubCat2Name VARCHAR(200),
				@ItemUnit VARCHAR(100),
				@CreatedUserID INT

				-- Fetch item data
				SELECT 
				@CompanyName = CO.Name,
				@ItemCode = ISNULL(TS.ItemCode,''),
				@ItemDescription = ISNULL(TS.ItemDescription,''),
				@Remarks = ISNULL(TS.Remarks,''),
				@CategoryName = ISNULL(CA.Name,''),
				@SubCatName = ISNULL(SC.Name,''),
				@SubCat2Name = ISNULL(SC2.Description,''),
				@ItemUnit = ISNULL(UN.Name,'')
				,@CreatedUserID = TS.CreatedUserID
				FROM TempStockItemRequest TS
				INNER JOIN COMPANIES CO ON TS.PROPERTYID = CO.CompanyID
				LEFT JOIN CATEGORIES CA ON TS.CategoryId = CA.ID
				LEFT JOIN SubCategories SC ON SC.Id = TS.SubCategoryId
				LEFT JOIN SubCategories02 SC2 ON SC2.Id = TS.SubCategory2Id
				LEFT JOIN Units UN ON UN.ID = TS.ItemUnit
				WHERE TS.ID = @HeaderID


				
				
				-- Compose HTML email
				SET @EmailBody = 
				'<html>
				<body>
				<h2>Item Master Creation</h2>
				<p>The following item has been requested for creation under company <strong>' + @CompanyName + '</strong>.</p>

				<table border="1" cellspacing="0" cellpadding="5" style="border-collapse: collapse; width: 100%;">
				<thead>
				<tr style="background-color: #f2f2f2;">
				<th>Item Code</th>
				<th>Item Description</th>
				<th>Category</th>
				<th>Sub Category</th>
				<th>Sub Category 2</th>
				<th>Unit</th>
				<th>Remarks</th>
				</tr>
				</thead>
				<tbody>
				<tr>
				<td>' + ISNULL(@ItemCode, '') + '</td>
				<td>' + ISNULL(@ItemDescription, '') + '</td>
				<td>' + ISNULL(@CategoryName, '') + '</td>
				<td>' + ISNULL(@SubCatName, '') + '</td>
				<td>' + ISNULL(@SubCat2Name, '') + '</td>
				<td>' + ISNULL(@ItemUnit, '') + '</td>
				<td>' + ISNULL(@Remarks, '') + '</td>
				</tr>
				</tbody>
				</table>

				<br><br>
				<p style="font-size:12px; color:gray;">
				<small>This email is auto-generated. Please do not reply.</small>
				</p>
				</body>
				</html>';

				

				SELECT X.*
				INTO #StockmasterList
				FROM 
				(
					select A.Id AS MenuItemId ,cu.UserId
					from CentralAccessDB..Admin_Nav_AreasWisePages A
					INNER JOIN  CentralAccessDB..[Central_UserRoleWiseMenuItems] B ON B.MenuItemId = A.Id and b.MenuItemId in (133)
					inner join CentralAccessDB..Central_UserWiseUserRoles cu on cu.UserRoleId = b.UserRoleId 
					inner join CentralAccessDB..Central_UserWiseProperties CP ON CP.UserId = CU.UserId AND CP.PropertyId=@PropertyId
					where 
					A.ModuleId = @ModuleId
					UNION
					SELECT A.MenuItemId, A.UserId
					FROM CentralAccessDB..[Central_UserWiseIndividualMenuItems] A
					WHERE 
					A.ModuleId = @ModuleId	and a.MenuItemId in (133)
					AND A.PropertyId=@PropertyId

				) AS X

						SELECT  d.userid,D.MenuItemId,b.email,
						(CASE ISNULL(D.MenuItemId,0) WHEN 0 THEN 0 ELSE 1 END) AS 'Access'
						into #userwiseEmail5
						FROM CentralAccessDB..Admin_Nav_AreasWisePages C
						inner JOIN #StockmasterList D ON C.Id = D.MenuItemId
						inner join CentralAccessDB..Central_Users B ON d.UserId = B.Id
						WHERE C.ModuleId = 4
						 AND C.IsActive=1 and D.MenuItemId in (133)
						 AND B.IsActive=1

						 --Sending Email copy to Item Requested User also
						 INSERT INTO #userwiseEmail5
						 SELECT CU.ID userid,133 MenuItemId,CU.Email email,1 Access
						 FROM CentralUsers CU
						 WHERE ID = @CreatedUserID
						 --End
 

						
						  --select userid,email from #userwiseEmail where MenuItemId = 2536
					SELECT @NewEmail = STRING_AGG(email, ';') FROM (SELECT DISTINCT email FROM #userwiseEmail5 WHERE MenuItemId IN (133)) AS DistinctEmails;


					

					INSERT INTO #TempEmail (UserID , UserName ,Email)
					VALUES(0,'',@NewEmail)

				
			END

			IF(@TransactionType = 'SM')-- Email send for Requested  Item Creation
			BEGIN

				DECLARE 
				@ItemCodeSM VARCHAR(100),
				@ItemDescriptionSM VARCHAR(MAX),
				@RemarksSM VARCHAR(MAX),
				@CategoryNameSM VARCHAR(200),
				@SubCatNameSM VARCHAR(200),
				@SubCat2NameSM VARCHAR(200),
				@ItemUnitSM VARCHAR(100),
				@CreatedUserIDSM INT,
				@StockItemHeaderIDSM INT

				-- Fetch item data
				SELECT 
				@CompanyName = CO.Name,
				@ItemCodeSM = ISNULL(SH.StockItemCode,''),
				@ItemDescriptionSM = ISNULL(TS.ItemDescription,''),
				@RemarksSM = ISNULL(TS.Remarks,''),
				@CategoryNameSM = ISNULL(CA.Name,''),
				@SubCatNameSM = ISNULL(SC.Name,''),
				@SubCat2NameSM = ISNULL(SC2.Description,'')
				,@CreatedUserIDSM = TS.CreatedUserID
				FROM TempStockItemRequest TS WITH (NOLOCK)
				INNER JOIN StockItemHeaders SH ON TS.StockItemHeaderID = SH.Id
				INNER JOIN COMPANIES CO WITH (NOLOCK) ON TS.PROPERTYID = CO.CompanyID
				LEFT JOIN CATEGORIES CA WITH (NOLOCK) ON TS.CategoryId = CA.ID
				LEFT JOIN SubCategories SC WITH (NOLOCK) ON SC.Id = TS.SubCategoryId
				LEFT JOIN SubCategories02 SC2 WITH (NOLOCK) ON SC2.Id = TS.SubCategory2Id
				WHERE TS.ID = @HeaderID


				
				
				-- Compose HTML email
				SET @EmailBody = 
				'<html>
				<body>
				<h2>Item Master Creation</h2>
				<p>The following item has been approved for creation under company <strong>' + @CompanyName + '</strong>.</p>

				<table border="1" cellspacing="0" cellpadding="5" style="border-collapse: collapse; width: 100%;">
				<thead>
				<tr style="background-color: #f2f2f2;">
				<th>Item Code</th>
				<th>Item Description</th>
				<th>Category</th>
				<th>Sub Category</th>
				<th>Sub Category 2</th>
				<th>Remarks</th>
				</tr>
				</thead>
				<tbody>
				<tr>
				<td>' + ISNULL(@ItemCodeSM, '') + '</td>
				<td>' + ISNULL(@ItemDescriptionSM, '') + '</td>
				<td>' + ISNULL(@CategoryNameSM, '') + '</td>
				<td>' + ISNULL(@SubCatNameSM, '') + '</td>
				<td>' + ISNULL(@SubCat2NameSM, '') + '</td>
				<td>' + ISNULL(@RemarksSM, '') + '</td>
				</tr>
				</tbody>
				</table>

				<br><br>
				<p style="font-size:12px; color:gray;">
				<small>This email is auto-generated. Please do not reply.</small>
				</p>
				</body>
				</html>';

				select @EmailBody

				--Sending Email copy to Item Requested User also
				SELECT CU.ID userid,133 MenuItemId,CU.Email email,1 Access
				INTO #userwiseEmaiLSM
				FROM CentralUsers CU
				WHERE ID = @CreatedUserIDSM
				--End	

			--select userid,email from #userwiseEmail where MenuItemId = 2536
			SELECT @NewEmail = STRING_AGG(email, ';') FROM (SELECT DISTINCT email FROM #userwiseEmaiLSM WHERE MenuItemId IN (133)) AS DistinctEmails;

			INSERT INTO #TempEmail (UserID , UserName ,Email)
			VALUES(0,'',@NewEmail)

				
			END
			--Sending user WIse emails

		--	SET @NewMailSubject = 'Approved '+@TransactionTypeName +' - '+ @LocationName+' - '+ @DocumentNo; -- added by Isuru 2025-02-27 for The specified string is not in the form required for a subject. issue
			SET @NewMailSubject = CASE WHEN @TransactionType = 'IC' THEN 'Stock Item Creation Request' 
								 WHEN @TransactionType = 'SC' THEN 'Supplier Creation Request'
								 WHEN @TransactionType = 'SM' THEN 'Stock Item Creation Approved'
								 ELSE 'Approved '+@TransactionTypeName END;

			WHILE EXISTS(SELECT 1  FROM #TempEmail)
			BEGIN
				SELECT TOP(1) @NewEmail= EMAIL,@NewApprovalUserID =UserID  FROM #TempEmail

			
				EXEC [dbo].[SendReuestMail] @NewEmail, @NewMailSubject, @EmailBody, 2

				IF(@TransactionType in ('RT','RI'))
				BEGIN
					UPDATE RequestHeaders
					SET SendMail = 1
					WHERE ID = @HeaderID AND IsApproved=1
				END

				IF(@TransactionType = 'TO')
				BEGIN
					UPDATE StockTransactionHeaders
					SET SendMail = 1
					WHERE ID = @HeaderID 
				END

				IF(@TransactionType ='CR')
				BEGIN
					UPDATE CommiRequestHeader
					SET SendMail = 1
					WHERE ID = @HeaderID
				END

					IF(@TransactionType = 'RP')
				BEGIN
					UPDATE RequestHeaders
					SET SendMail = 1
					WHERE ID = @HeaderID AND IsApproved=1
				END
				DELETE TOP (1) FROM #TempEmail
			END
			--End
		END

		IF(@Operation = 'P')
		BEGIN
			IF(@TransactionType ='S1')
			BEGIN
						INSERT INTO #TempStockSpotHeader
				SELECT SH.StockItemCode,SH.Name,ROUND(SD.QuantityInHand,2) QuantityInHand,ROUND(SD.PhysicalQty,2) PhysicalQty 
					FROM StockSpotCheckDetail SD
					INNER JOIN StockItemHeaders SH ON SH.Id = SD.StockItemID
					WHERE SD.StockSpotHeaderID = @HeaderID
			
				SELECT  @DocumentNo= PH.DocNo,@RequestedUser= CU.UserName,@LocationName = LO.Name, @CompanyName = CO.Name 
				FROM StockSpotCheckHeader PH
				INNER JOIN Locations LO ON PH.LocationID = LO.Id
				INNER JOIN CentralUsers CU ON CU.Id = PH.UserID
				INNER JOIN Companies CO ON CO.CompanyID = PH.PropertyID
				WHERE PH.Id=@HeaderID

				SET @EmailBody ='<p style="font-size:12px;color:gray;">
					You have to respond a pending approval
					<br><br>
				</p>' +
				'<table border="1" style="border-collapse: collapse; width: 100%;">' +
				'<thead>' +
				'<tr><th>Code</th><th>Name</th><th>System Qty In Hand</th><th>Physical Quantity</th></tr>' +
				'</thead>' +
				'<tbody>' +
				(
					SELECT STRING_AGG(
						'<tr><td>' + CAST(StockItemCode AS VARCHAR(20)) + 
						'</td><td>' + CAST(Name AS VARCHAR(20)) + 
						'</td><td>' + CAST(QuantityInHand AS VARCHAR(20)) + 
						 '</td><td>' + CAST(PhysicalQty AS VARCHAR(20)) + 
						'</td></tr>', 
						''
					) AS [text()]
					FROM #TempStockSpotHeader
				) +
				'</tbody>' +
				'</table>';		
				SELECT X.*
				INTO #AccessibleMenuItems
				FROM 
				(
					select A.Id AS MenuItemId ,cu.UserId
					from CentralAccessDB..Admin_Nav_AreasWisePages A
					INNER JOIN  CentralAccessDB..[Central_UserRoleWiseMenuItems] B ON B.MenuItemId = A.Id and b.MenuItemId in (2536)
					inner join CentralAccessDB..Central_UserWiseUserRoles cu on cu.UserRoleId = b.UserRoleId 
					where 
					A.ModuleId = @ModuleId
					UNION
					SELECT A.MenuItemId, A.UserId
					FROM CentralAccessDB..[Central_UserWiseIndividualMenuItems] A
					WHERE 
					A.ModuleId = @ModuleId	and a.MenuItemId in (2536)
					AND A.PropertyId=@PropertyId

				) AS X

						SELECT  d.userid,D.MenuItemId,b.email,
						(CASE ISNULL(D.MenuItemId,0) WHEN 0 THEN 0 ELSE 1 END) AS 'Access'
						into #userwiseEmail
						FROM CentralAccessDB..Admin_Nav_AreasWisePages C
						inner JOIN #AccessibleMenuItems D ON C.Id = D.MenuItemId
						inner join CentralAccessDB..Central_Users B ON d.UserId = B.Id
						WHERE C.ModuleId = 4
						 AND C.IsActive=1 and D.MenuItemId in (2536)

						  --select userid,email from #userwiseEmail where MenuItemId = 2536
					SELECT @NewEmail = STRING_AGG(email, ';')  FROM #userwiseEmail where MenuItemId = 2536
					SET @TransactionTypeName = 'Stock Spot Check'

			END

			IF(@TransactionType ='S2')
			BEGIN
						INSERT INTO #TempStockSpotHeader
				SELECT SH.StockItemCode,SH.Name,ROUND(SD.QuantityInHand,2) QuantityInHand,ROUND(SD.PhysicalQty,2) PhysicalQty 
					FROM StockSpotCheckDetail SD
					INNER JOIN StockItemHeaders SH ON SH.Id = SD.StockItemID
					WHERE SD.StockSpotHeaderID = @HeaderID
			
				SELECT  @DocumentNo= PH.DocNo,@RequestedUser= CU.UserName,@LocationName = LO.Name, @CompanyName = CO.Name 
				FROM StockSpotCheckHeader PH
				INNER JOIN Locations LO ON PH.LocationID = LO.Id
				INNER JOIN CentralUsers CU ON CU.Id = PH.UserID
				INNER JOIN Companies CO ON CO.CompanyID = PH.PropertyID
				WHERE PH.Id=@HeaderID

				SET @EmailBody ='<p style="font-size:12px;color:gray;">
					You have to respond a pending approval
					<br><br>
				</p>' +
				'<table border="1" style="border-collapse: collapse; width: 100%;">' +
				'<thead>' +
				'<tr><th>Code</th><th>Name</th><th>System Qty In Hand</th><th>Physical Quantity</th></tr>' +
				'</thead>' +
				'<tbody>' +
				(
					SELECT STRING_AGG(
						'<tr><td>' + CAST(StockItemCode AS VARCHAR(20)) + 
						'</td><td>' + CAST(Name AS VARCHAR(20)) + 
						'</td><td>' + CAST(QuantityInHand AS VARCHAR(20)) + 
						 '</td><td>' + CAST(PhysicalQty AS VARCHAR(20)) + 
						'</td></tr>', 
						''
					) AS [text()]
					FROM #TempStockSpotHeader
				) +
				'</tbody>' +
				'</table>';		

				SELECT X.*
				INTO #AccessibleMenuItems2
				FROM 
				(
					select A.Id AS MenuItemId ,cu.UserId
					from CentralAccessDB..Admin_Nav_AreasWisePages A
					INNER JOIN  CentralAccessDB..[Central_UserRoleWiseMenuItems] B ON B.MenuItemId = A.Id and b.MenuItemId in (2535)
					inner join CentralAccessDB..Central_UserWiseUserRoles cu on cu.UserRoleId = b.UserRoleId 
					where 
					A.ModuleId = @ModuleId
					UNION
					SELECT A.MenuItemId, A.UserId
					FROM CentralAccessDB..[Central_UserWiseIndividualMenuItems] A
					WHERE 
					A.ModuleId = @ModuleId	and a.MenuItemId in (2535)
					AND A.PropertyId=@PropertyId

				) AS X

						SELECT  d.userid,D.MenuItemId,b.email,
						(CASE ISNULL(D.MenuItemId,0) WHEN 0 THEN 0 ELSE 1 END) AS 'Access'
						into #userwiseEmail2
						FROM CentralAccessDB..Admin_Nav_AreasWisePages C
						inner JOIN #AccessibleMenuItems2 D ON C.Id = D.MenuItemId
						inner join CentralAccessDB..Central_Users B ON d.UserId = B.Id
						WHERE C.ModuleId = 4
						 AND C.IsActive=1 and D.MenuItemId in (2535)

						  --select userid,email from #userwiseEmail where MenuItemId = 2536
					SELECT @NewEmail = STRING_AGG(email, ';')  FROM #userwiseEmail2 where MenuItemId = 2535
					SET @TransactionTypeName = 'Stock Spot Check'
	
			END
			--Sending user WIse emails
			if @TransactionTypeName is null set @TransactionTypeName = ''
			if @LocationName is null set @LocationName = ''
			if @DocumentNo is null set @DocumentNo =''
			declare @mesBody varchar(100);
			SET @mesBody = CASE WHEN @TransactionType = 'S1' THEN 'Stock Spot Check First Approval ' ELSE 'Stock Spot Check Second Approval ' END

			SET @NewMailSubject = @mesBody +' - '+ @LocationName+' - '+ @DocumentNo;

			IF @NewEmail IS NOT NULL
			BEGIN
				EXEC [dbo].[SendReuestMail] @NewEmail, @NewMailSubject, @EmailBody, 2
			END
		
		END

		IF(@Operation = 'X') -- when rejected
		BEGIN
			IF(@TransactionType ='RP')  -- Email Send for purchase Request 
			BEGIN
				INSERT INTO #TempEmail(UserID, UserName,Email)
				SELECT CU.Id UserID,CU.UserName,CU.Email
				FROM RequestHeaders RH
				INNER JOIN CentralUsers CU ON RH.UserProfileID = CU.Id
				WHERE RH.Id =  @HeaderID 
				AND RH.PropertyID =@PropertyID
			

				SELECT @DocumentNo= DocumentNo,@RequestedUser= CU.UserName,@LocationName = LO.Name, @CompanyName = CO.Name 
				FROM RequestHeaders RH
				INNER JOIN Locations LO ON RH.LocationID = LO.Id
				INNER JOIN CentralUsers CU ON CU.Id = RH.LastModUserID
				INNER JOIN Companies CO ON CO.CompanyID = RH.PropertyID
				WHERE RH.Id = @HeaderID		

				SET @EmailBody = '<html><body><p>Your transaction submission has been declined</p>
							  <table border = 1>
							  <thead>
								  <th  style="width: 20%" >Transaction type</th>
								  <th  style="width: 20%" >Document Number</th>
								  <th  style="width: 20%" >Company Name</th>
								  <th  style="width: 20%" >Location Name</th>
								  <th  style="width: 20%" >Rejected User</th>
							  </thead>
							  <tbody >
								<tr>
								 <td  style="width: 20%" >'+@TransactionTypeName+'</td>
								 <td  style="width: 20%" >'+@DocumentNo+'</td>
								 <td  style="width: 20%" >'+@CompanyName+'</td>
								 <td  style="width: 20%" >'+@LocationName+'</td>
								 <td  style="width: 20%" >'+@RequestedUser+'</td>
								</tr>
							  </tbody>
							  </table></html></body>'
			END



			IF(@TransactionType = 'PO') -- Email Send for purchase Order 
			BEGIN

				INSERT INTO #TempEmail(UserID, UserName,Email)
				SELECT CU.Id UserID,CU.UserName,CU.Email
				FROM POHEADERS PH
				INNER JOIN CentralUsers CU ON PH.UserProfileID = CU.Id
				WHERE PH.Id =  @HeaderID 
				AND PH.PropertyID =@PropertyID
			
			
				SELECT @DocumentNo= PoNo,@RequestedUser= CU.UserName,@LocationName = LO.Name, @CompanyName = CO.Name 
				FROM POHEADERS PH
				INNER JOIN Locations LO ON PH.LocationID = LO.Id
				INNER JOIN CentralUsers CU ON CU.Id = PH.LastModUserID
				INNER JOIN Companies CO ON CO.CompanyID = PH.PropertyID
				WHERE PH.Id = @HeaderID 

				SET @EmailBody = '<html><body><p>Your transaction submission has been declined</p>
							  <table border = 1>
							  <thead>
								  <th  style="width: 20%" >Transaction type</th>
								  <th  style="width: 20%" >Document Number</th>
								  <th  style="width: 20%" >Company Name</th>
								  <th  style="width: 20%" >Location Name</th>
								  <th  style="width: 20%" >Rejected User</th>
							  </thead>
							  <tbody >
								<tr>
								 <td  style="width: 20%" >'+@TransactionTypeName+'</td>
								 <td  style="width: 20%" >'+@DocumentNo+'</td>
								 <td  style="width: 20%" >'+@CompanyName+'</td>
								 <td  style="width: 20%" >'+@LocationName+'</td>
								 <td  style="width: 20%" >'+@RequestedUser+'</td>
								</tr>
							  </tbody>
							  </table></html></body>'

			END


				--Sending user WIse emails

			WHILE EXISTS(SELECT 1  FROM #TempEmail)
			BEGIN
				SELECT TOP(1) @NewEmail= EMAIL,@NewApprovalUserID =UserID  FROM #TempEmail

				EXEC [dbo].[SendReuestMail] @NewEmail, 'Rejected Transaction', @EmailBody, 2

				IF(@TransactionType in ('RP','RI'))
				BEGIN
					UPDATE RequestHeaders
					SET SendMail = 1
					WHERE ID = @HeaderID AND IsApproved=1
				END
				DELETE TOP (1) FROM #TempEmail
			END
			--End

		END
	END
END

GO

