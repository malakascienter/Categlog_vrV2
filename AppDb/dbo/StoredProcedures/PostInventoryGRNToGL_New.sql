
-- exec [dbo].[PostInventoryGRNToGL_New] 2


CREATE PROCEDURE [dbo].[PostInventoryGRNToGL_New](@StockTransactionHeaderID INT)
as

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


DECLARE @Object AS INT,@TaxTotal DECIMAL(18,2) = 0, @InvoiceNo Varchar(max)
DECLARE @ResponseTable AS TABLE(ResponseValue VARCHAR(MAX))
 
DECLARE @ResponseText AS VARCHAR(8000);
DECLARE @RequestLength AS INT, @RequestBody VARCHAR(2000),   @description VARCHAR(255), @GRNNumber VARCHAR(200), @SupplierName VARCHAR(MAX)

declare @DocumentNo varchar(200), @SupplierCode varchar(50),@TransType varchar(50), @TxnDate char(10), 
@Total DECIMAL(18,6), @TxnDrList varchar(max)='', @TxnCrList varchar(max)='', @CompanyCode varchar(50), 
@MasterID varchar(50),@TransactionType varchar(10), @docID int, @OPNUmber Varchar(12)


--select * from Suppliers
--ADDED BY ISURUT 2023-02-03
DECLARE @AdditionalCharge DECIMAL(18,6)

select @AdditionalCharge = ISNULL(SUM(ST.ChargeAmount),0)
from StockTransactionHeaders h
INNER JOIN StockTransactionwiseCharges ST ON ST.StockTransactionHeaderID = h.Id
INNER JOIN Companies co on co.CompanyID = h.PropertyID 
where  h.ID=@StockTransactionHeaderID
--END


select	@MasterID= c.MasterID, @CompanyCode =c.Code,  @DocumentNo =h.DocumentNo,@SupplierCode=s.BSPCODE, 
		@TxnDate=convert(varchar,h.TransactionDate,102), @TransType= TransactionType, @Total =sum(d.Quantity * d.UnitPrice)- SUM( CASE WHEN D.DiscountValue=0 THEN d.Quantity * d.UnitPrice * d.DiscountPercentage /100 ELSE  D.DiscountValue END )+@AdditionalCharge,
		@InvoiceNo= isnull(ReferenceNo,''), @TransactionType = TransactionType, @SupplierName= s.Name
from StockTransactionHeaders h
inner join StockTransactionDetails d 
on d.StockTransactionHeaderID=h.id
inner join Suppliers s on s.id = h.supplierid
inner join Companies c on c.CompanyID = h.PropertyID
where h.id= @StockTransactionHeaderID --and TransactionType='GR'
group by h.DocumentNo, h.TransactionDate, h.TransactionType,s.BSPCODE,c.MasterID,c.Code,ReferenceNo,s.Name
 

 SELECT  @AppUser= CU.UniqueId
FROM StockTransactionHeaders SH
INNER JOIN CentralUsers CU ON SH.CreatedUserID = CU.Id
WHERE SH.Id = @StockTransactionHeaderID

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

declare @TxnList as TABLE ([Id] [int] IDENTITY(1,1) NOT NULL,  AccCode varchar(12), Amount DECIMAL(18,6), DrCr CHAR(1))


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

--ADDED BY ISURUT 2023-02-03
UNION ALL
select g.ACCCODE, SUM(ST.ChargeAmount), 'D'
from StockTransactionHeaders h
INNER JOIN StockTransactionwiseCharges ST ON ST.StockTransactionHeaderID = h.Id
INNER JOIN AdditionalChargesDetails AD ON AD.Id = ST.AdditionalChargeID
INNER JOIN	[dbo].[Destinity_GLIntegrationAccountMapping] G ON G.BLOCKCODE='ADD' AND G.Level1 = ST.AdditionalChargeID
INNER JOIN Companies co on co.CompanyID = h.PropertyID AND G.GLCOMPCODE= CO.Code
where  h.ID=@StockTransactionHeaderID
group by  g.AccCode

delete @TxnList where Amount=0
--END

declare @AccCode varchar(12), @Amount DECIMAL(18,6),@DrCr char(1), @i as int =1

SET @DocDrDetails	=''

DECLARE @RC INT

SELECT @RC = COUNT(*) FROM @TxnList

while @RC >0
begin

	select  @AccCode =AccCode, @Amount = amount, @DrCr= DrCr
	from @TxnList
	WHERE Id = @RC

    --commented by Isuru 2026-10-23 to send full narration same as CrNarration
	--SET @DocDrDetails = @DocDrDetails + '
 --   <DrDatalList>
 --       <ModCrNoteNo>' +
 --           REPLACE(REPLACE(REPLACE(ISNULL(@GRNNumber, ''), '&', '&amp;'), '<', '&lt;'), '>', '&gt;') +
 --       '</ModCrNoteNo>
 --       <MASTERID>' + @MasterID + '</MASTERID>
 --       <SeqNo>' + CONVERT(VARCHAR(250), @RC) + '</SeqNo>
 --       <DrAccCode>' + @AccCode + '</DrAccCode>
 --       <DrNarration>GRN :' +
 --           REPLACE(REPLACE(REPLACE(ISNULL(@DocumentNo, ''), '&', '&amp;'), '<', '&lt;'), '>', '&gt;') +
 --       '</DrNarration>
 --       <Amount>' + CONVERT(VARCHAR(MAX), @Amount, 6) + '</Amount>
 --       <DocId>' + CONVERT(VARCHAR(250), @docID) + '</DocId>
 --   </DrDatalList>'

 SET @DocDrDetails = @DocDrDetails + '
    <DrDatalList>
        <ModCrNoteNo>' +
            REPLACE(REPLACE(REPLACE(ISNULL(@GRNNumber, ''), '&', '&amp;'), '<', '&lt;'), '>', '&gt;') +
        '</ModCrNoteNo>
        <MASTERID>' + @MasterID + '</MASTERID>
        <SeqNo>' + CONVERT(VARCHAR(250), @RC) + '</SeqNo>
        <DrAccCode>' + @AccCode + '</DrAccCode>
        <DrNarration>' +
                'Supplier -' +
                REPLACE(REPLACE(REPLACE(ISNULL(@SupplierName, ''), '&', '&amp;'), '<', '&lt;'), '>', '&gt;') +
                ', SuppInvNO: ' +
                REPLACE(REPLACE(REPLACE(ISNULL(@InvoiceNO, ''), '&', '&amp;'), '<', '&lt;'), '>', '&gt;') +
                ', ' +
                CASE
                    WHEN @DocID = 1 THEN 'GRN'
                    ELSE 'GRN- ' +
                        REPLACE(REPLACE(REPLACE(ISNULL(@GRNNumber, ''), '&', '&amp;'), '<', '&lt;'), '>', '&gt;') +
                        ', SRN'
                END +
                ' - ' +
                REPLACE(REPLACE(REPLACE(ISNULL(@DocumentNo, ''), '&', '&amp;'), '<', '&lt;'), '>', '&gt;') +
        '</DrNarration>
        <Amount>' + CONVERT(VARCHAR(MAX), @Amount, 6) + '</Amount>
        <DocId>' + CONVERT(VARCHAR(250), @docID) + '</DocId>
    </DrDatalList>'

		-- <DrNarration>' + 'GRN :'+@DocumentNo+'-'+REPLACE(@SupplierCode,'&','')+'/'+REPLACE(@SupplierName,'&','')+'/'+REPLACE(@InvoiceNo,'&','')+ '</DrNarration>
	
	SET @RC = @RC -1


END 
SET  @DocDrDetails= '<ArrayOfDrDatalList>'+ @DocDrDetails+'</ArrayOfDrDatalList>'

select @DocDrDetails DocDrDetails
SET @TxnDrList=''


Declare @APTaxList varchar(max)='', @TaxID int, @TaxAmount DECIMAL(18,2) , @TaxRate DECIMAL(18,2) 

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

	SET @TaxTotal +=@TaxAmount
	SET @DocTax =  @DocTax +'
		<APTaxList>
		<MasterID>' +  CONVERT(VARCHAR(250),@MasterID) + '</MasterID>
		<ModCrNoteNo>' +
		REPLACE(REPLACE(REPLACE(ISNULL(@GRNNumber, ''), '&', '&amp;'), '<', '&lt;'), '>', '&gt;') +
	'</ModCrNoteNo>
		<DocId>' +  CONVERT(VARCHAR(250),@docID) + '</DocId>
		<TaxID>' +  CONVERT(VARCHAR(250),@TaxID) + '</TaxID>
		<TaxRate>' +  CONVERT(VARCHAR(250),@TaxRate) + '</TaxRate>
		<TaxAmount>' +  CONVERT(VARCHAR(MAX),@TaxAmount,2) + '</TaxAmount>
		</APTaxList>
		'


	DELETE FROM #TaxList
	WHERE TaxTypeID =@TaxID
 END 

  SET @DocTax = '<ArrayOfAPTaxList>'+@DocTax+'</ArrayOfAPTaxList>'

  --<CrNarration>' + 'Supplier -'+ Isnull( REPLACE(@SupplierName, '&', '&amp;') ,'') +', '+ CASE WHEN @DocID =1 THEN 'GRN' ELSE +'GRN- '+ @GRNNUmber +', SRN' END +' - '+ @DocumentNo +'</CrNarration>


SET @DocDetails =
    '<ArrayOfCrHeaderDataList>
        <CrHeaderDataList>
            <DocId>' +
                REPLACE(REPLACE(REPLACE(ISNULL(CONVERT(VARCHAR(250), @DocID), ''), '&', '&amp;'), '<', '&lt;'), '>', '&gt;') +
            '</DocId>
            <MasterID>' +
                REPLACE(REPLACE(REPLACE(ISNULL(CONVERT(VARCHAR(250), @MasterID), ''), '&', '&amp;'), '<', '&lt;'), '>', '&gt;') +
            '</MasterID>
            <BSPCode>' +
                REPLACE(REPLACE(REPLACE(ISNULL(@SupplierCode, ''), '&', '&amp;'), '<', '&lt;'), '>', '&gt;') +
            '</BSPCode>
            <ModCrNoteNo>' +
                REPLACE(REPLACE(REPLACE(ISNULL(@GRNNumber, ''), '&', '&amp;'), '<', '&lt;'), '>', '&gt;') +
            '</ModCrNoteNo>
            <CrNarration>' +
                'Supplier -' +
                REPLACE(REPLACE(REPLACE(ISNULL(@SupplierName, ''), '&', '&amp;'), '<', '&lt;'), '>', '&gt;') +
                ', SuppInvNO: ' +
                REPLACE(REPLACE(REPLACE(ISNULL(@InvoiceNO, ''), '&', '&amp;'), '<', '&lt;'), '>', '&gt;') +
                ', ' +
                CASE
                    WHEN @DocID = 1 THEN 'GRN'
                    ELSE 'GRN- ' +
                        REPLACE(REPLACE(REPLACE(ISNULL(@GRNNumber, ''), '&', '&amp;'), '<', '&lt;'), '>', '&gt;') +
                        ', SRN'
                END +
                ' - ' +
                REPLACE(REPLACE(REPLACE(ISNULL(@DocumentNo, ''), '&', '&amp;'), '<', '&lt;'), '>', '&gt;') +
            '</CrNarration>
            <UserID>' +
                REPLACE(REPLACE(REPLACE(ISNULL(CONVERT(VARCHAR(MAX), @AppUser), ''), '&', '&amp;'), '<', '&lt;'), '>', '&gt;') +
            '</UserID>
            <Module>I</Module>
            <ModProType></ModProType>
            <ModRefNo>' +
                REPLACE(REPLACE(REPLACE(ISNULL(@GRNNumber, ''), '&', '&amp;'), '<', '&lt;'), '>', '&gt;') +
            '</ModRefNo>
            <MFCenter></MFCenter>
            <PostMethod></PostMethod>
            <CurLevel></CurLevel>
            <PostLevel></PostLevel>
            <TaxPack></TaxPack>
            <TransType>0</TransType>
            <SuppInvNO>' +
                REPLACE(REPLACE(REPLACE(ISNULL(@InvoiceNO, ''), '&', '&amp;'), '<', '&lt;'), '>', '&gt;') +
            '</SuppInvNO>
            <RefNo>' +
                REPLACE(REPLACE(REPLACE(ISNULL(@OPNumber, ''), '&', '&amp;'), '<', '&lt;'), '>', '&gt;') +
            '</RefNo>
            <DocDate>' +
                REPLACE(REPLACE(REPLACE(ISNULL(@TxnDate, ''), '&', '&amp;'), '<', '&lt;'), '>', '&gt;') +
            '</DocDate>
            <TotalDocAmt>' +
                REPLACE(REPLACE(REPLACE(ISNULL(CONVERT(VARCHAR(50), @Total + @taxTotal), ''), '&', '&amp;'), '<', '&lt;'), '>', '&gt;') +
            '</TotalDocAmt>
        </CrHeaderDataList>
    </ArrayOfCrHeaderDataList>';


SET @DocSegDetails = '<ArrayOfSegmentList></ArrayOfSegmentList>'

SELECT convert(varchar,@Total +@taxTotal) TOT,@Total Total,@taxTotal taxTotal,@Total +@taxTotal


SET @TxnCurr = 'LKR'
SET @ExchangeRate = 1
SET @MulComCode = @companyCode
SET @DocumentNo = @DocumentNo

select 'APII', @Module , @DocDetails,@DocDrDetails, @DocSegDetails, @DocTax, @AppUser,@TxnCurr,@ExchangeRate,@MulComCode,@CrDrNo

EXEC [dbo].[Destinity_AP_Populate_OtherModAPposting] @Module , @DocDetails,@DocDrDetails, @DocSegDetails, @DocTax, @AppUser,@TxnCurr,@ExchangeRate,@MulComCode,@CrDrNo


END TRY
BEGIN CATCH
		 		
		SELECT	@sErrorProcedure=ERROR_PROCEDURE()
		SELECT	@sErrorMessage	= ERROR_MESSAGE()
		SELECT	@iErrorNumber=ERROR_NUMBER()

		SELECT @sErrorProcedure ErrorProcedure,@sErrorMessage ErrorMessage,@iErrorNumber ErrorNumber

		RAISERROR (@sErrorMessage,16,1)

		RETURN 0
	END CATCH
END

GO

