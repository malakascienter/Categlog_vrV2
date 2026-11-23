
CREATE PROCEDURE [dbo].[SP_PostInventoryGRNToGLExtra](@StockTransactionHeaderID INT)
AS

BEGIN
 BEGIN TRY  
	DECLARE @Module				CHAR(1) = 'I',
		@DocDetails				XML,
		@DocDrDetails			VARCHAR(MAX),
		@DocSegDetails			VARCHAR(MAX),
		@DocTax					VARCHAR(MAX),
		@AppUser				UNIQUEIDENTIFIER,
		--@AppUser				nvarchar(256),
		@TxnCurr				CHAR(3),
		@ExchangeRate			BIT,
		@MulComCode				CHAR(3),
		@CrDrNo					VARCHAR(14) = ''

	DECLARE @iErrorNumber		INT,
			@sErrorMessage		VARCHAR(250),
			@sErrorProcedure	VARCHAR(50)


	DECLARE @Object AS INT,@TaxTotal MONEY = 0, @InvoiceNo Varchar(max)
	DECLARE @ResponseTable AS TABLE(ResponseValue VARCHAR(MAX))
 
	DECLARE @ResponseText AS VARCHAR(8000);
	DECLARE @RequestLength AS INT, @RequestBody VARCHAR(2000),   @description VARCHAR(255), @GRNNumber VARCHAR(12), @SupplierName VARCHAR(MAX)

	declare @DocumentNo varchar(50), @SupplierCode varchar(50),@TransType varchar(50), @TxnDate char(10), 
	@Total money, @TxnDrList varchar(max)='', @TxnCrList varchar(max)='', @CompanyCode varchar(50), 
	@MasterID varchar(50),@TransactionType varchar(10), @docID int, @OPNUmber Varchar(12)


	select	@MasterID= c.MasterID, @CompanyCode =c.Code,  @DocumentNo =h.DocumentNo,@SupplierCode=s.BSPCODE, 
			@TxnDate=convert(varchar,h.TransactionDate,102), @TransType= TransactionType, @Total =sum(d.Quantity * d.UnitPrice)- SUM( CASE WHEN D.DiscountValue=0 THEN d.Quantity * d.UnitPrice * d.DiscountPercentage /100 ELSE  D.DiscountValue END ),
			@InvoiceNo= isnull(ReferenceNo,''), @TransactionType = TransactionType, @SupplierName= s.Name
	from StockTransactionHeaders h
	inner join StockTransactionDetails d 
	on d.StockTransactionHeaderID=h.id
	inner join Suppliers s on s.id = h.supplierid
	inner join Companies c on c.CompanyID = h.PropertyID
	where h.id= @StockTransactionHeaderID --and TransactionType='GR'
	group by h.DocumentNo, h.TransactionDate, h.TransactionType,s.BSPCODE,c.MasterID,c.Code,ReferenceNo,s.Name
 
 
 --select @TransactionType
	IF @TransactionType='GR' 
	BEGIN

		SET @GRNNumber=@DocumentNo

		SELECT @OPNUmber = PoNo 
		FROM StockTransactionHeaders S
		INNER JOIN POHeaders P ON p.ID= S.ReferenceID
		WHERE S.ID = @StockTransactionHeaderID

		SET @OPNumber= ISNULL(@OPNumber,'')

	END 
	ELSE
	BEGIN

		SELECT @GRNNumber= GR.DocumentNo FROM StockTransactionHeaders GR
		INNER JOIN StockTransactionHeaders SR ON GR.ID= SR.ReferenceID
		WHERE SR.ID = @StockTransactionHeaderID

		SET @OPNumber=@GRNNumber

	END 

 

	SET @DocID = CASE WHEN @TransactionType='GR' THEN  1 ELSE 5 END 




	if @DocumentNo is null
	begin
		return 0
	end 

	declare @TxnList as TABLE (AccCode varchar(12), Amount money, DrCr CHAR(1))


	INSERT @TxnList (AccCode,Amount,DrCr )

	select g.ACCCODE, sum(d.quantity* d.unitprice) - SUM( CASE WHEN D.DiscountValue=0 THEN d.Quantity * d.UnitPrice * d.DiscountPercentage /100 ELSE  D.DiscountValue END ), 'D'
	from StockTransactionHeaders h
	INNER JOIN	StockTransactionDetails d on d.StockTransactionHeaderID=h.id
	INNER JOIN	StockItemHeaders S ON S.ID = D.StockItemID
	INNER JOIN	Locations L ON L.ID = H.LocationID
	INNER JOIN	Categories C ON C.ID= s.CategoryID
	INNER JOIN	[dbo].[Destinity_GLIntegrationAccountMapping] G ON G.BLOCKCODE='GRN'
				AND G.Level1 = L.Code AND G.Level2 = C.Code
	INNER JOIN Companies co on co.CompanyID = h.PropertyID AND G.GLCOMPCODE= CO.Code
	where  h.ID=@StockTransactionHeaderID
	group by  g.AccCode



	declare @AccCode varchar(12), @Amount money,@DrCr char(1), @i as int =1

SET @DocDrDetails	=''
while exists (select top 1 AccCode from @TxnList)
begin

	select top (1) @AccCode =AccCode, @Amount = amount, @DrCr= DrCr  
	from @TxnList WHERE amount > 0

	--select @AccCode , @Amount , @DrCr  ,''

 	SET @DocDrDetails =@DocDrDetails+ '
					<DrDatalList>
						<ModCrNoteNo>' + @GRNNumber + '</ModCrNoteNo>
						<MASTERID>' + @MasterID + '</MASTERID>
						<SeqNo>' +  CONVERT(VARCHAR(250),@i) + '</SeqNo>
						<DrAccCode>' + @AccCode + '</DrAccCode>
						<DrNarration>' + 'GRN :'+@DocumentNo+ '</DrNarration>
						<Amount>' +  CONVERT(VARCHAR(MAX),@Amount) + '</Amount>
						<DocId>' + CONVERT(VARCHAR(250),@docID) + '</DocId>
					</DrDatalList>'

	set @i+=1
	delete from @TxnList 
	where AccCode=@AccCode and DrCr= @DrCr

end 
set  @DocDrDetails= '<ArrayOfDrDatalList>'+ @DocDrDetails+'</ArrayOfDrDatalList>'
	
	
	set @TxnDrList=''


	Declare @APTaxList varchar(max)='', @TaxID int, @TaxAmount money , @TaxRate money 

	SELECT S.TaxTypeID,T.Rate,Sum(TaxAmount) TaxAmount 
	INTO #TaxList
	FROM StockTransactionwiseTaxes S
	INNER JOIN TaxDetails T ON S.TaxTypeID= T.TaxTypeID
	INNER JOIN [dbo].[StockTransactionDetails] D ON D.ID= S.[StockTransactionDetailID]
	WHERE StockTransactionHeaderID=@StockTransactionHeaderID
	GROUP BY S.TaxTypeID,T.Rate

	SET @DocTax =''
WHILE EXISTS(SELECT TOP 1 TaxTypeID FROM #TaxList)
BEGIN
	SELECT TOP 1 @TaxID = TaxTypeID, @TaxAmount= TaxAmount, @TaxRate=Rate
	FROM #TaxList


	--select @TaxID , @TaxAmount, @TaxRate

	 

	SET @TaxTotal +=@TaxAmount
SET @DocTax =  @DocTax +'
					<APTaxList>
						<MasterID>' +  CONVERT(VARCHAR(250),@MasterID) + '</MasterID>
						<ModCrNoteNo>' + @GRNNumber + '</ModCrNoteNo>
						<DocId>' +  CONVERT(VARCHAR(250),@docID) + '</DocId>
						<TaxID>' +  CONVERT(VARCHAR(250),@TaxID) + '</TaxID>
						<TaxRate>' +  CONVERT(VARCHAR(250),@TaxRate) + '</TaxRate>
						<TaxAmount>' +  CONVERT(VARCHAR(MAX),@TaxAmount) + '</TaxAmount>
					</APTaxList>
					'



	DELETE FROM #TaxList
	WHERE TaxTypeID =@TaxID
 END 

 SET @DocTax = '<ArrayOfAPTaxList>'+@DocTax+'</ArrayOfAPTaxList>'



 
--------------Added--------------------------
SET @DocDetails ='
				  <ArrayOfCrHeaderDataList>
				  <CrHeaderDataList>
					<DocId>' + CONVERT(VARCHAR(250), @DocID) + '</DocId>
					<MasterID>' +  CONVERT(VARCHAR(250),@MasterID) + '</MasterID>
					<BSPCode>' + @SupplierCode + '</BSPCode>
					<ModCrNoteNo>' + @GRNNumber + '</ModCrNoteNo>
					<CrNarration>' + 'GRN :'+@DocumentNo + '</CrNarration>
					<UserID>' + 'B490B26A-2886-4671-8253-A8644C76660F' + '</UserID>
					<Module>' + 'I' + '</Module>
					<ModProType>' + '' + '</ModProType>
					<ModRefNo>' + @GRNNumber + '</ModRefNo>
					<MFCenter>' + '' + '</MFCenter>
					<PostMethod>' + '' + '</PostMethod>
					<CurLevel>' + '' + '</CurLevel>
					<PostLevel>' + '' + '</PostLevel>
					<TaxPack>' + '' + '</TaxPack>
					<TransType>0</TransType>
					<SuppInvNO>' + @InvoiceNO + '</SuppInvNO>
					<RefNo>' + @OPNumber + '</RefNo>
					<DocDate>'+ @TxnDate +'</DocDate>
					<TotalDocAmt>'+CONVERT(VARCHAR(MAX),isnull(@total+@taxTotal,0))+'</TotalDocAmt>
				</CrHeaderDataList>
				</ArrayOfCrHeaderDataList>'



--select @GRNNumber, @MasterID,@i, @DocumentNo,@Amount,@docID
SET @DocSegDetails = '<ArrayOfSegmentList></ArrayOfSegmentList>'

SET @AppUser = 'b490b26a-2886-4671-8253-a8644c76660f'
SET @TxnCurr = 'LKR'
SET @ExchangeRate = 1
SET @MulComCode = @companyCode

select 'APII',
@Module , @DocDetails,@DocDrDetails, @DocSegDetails, @DocTax, @AppUser,@TxnCurr,@ExchangeRate,@MulComCode,@CrDrNo
--------------Added---------------------------

EXEC [dbo].[Destinity_AP_Populate_OtherModAPposting] @Module , @DocDetails,@DocDrDetails, @DocSegDetails, @DocTax, @AppUser,@TxnCurr,@ExchangeRate,@MulComCode,@CrDrNo
--------------Added---------------------------
 END TRY
BEGIN CATCH
		 		
		SELECT	@sErrorProcedure=ERROR_PROCEDURE()
		SELECT	@sErrorMessage	= ERROR_MESSAGE()
		SELECT	@iErrorNumber=ERROR_NUMBER()

		RAISERROR (@sErrorMessage,16,1)

		RETURN 0
	END CATCH
END

GO

