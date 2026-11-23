


CREATE PROCEDURE [dbo].[CheckGLMappings_FroExcel](@StockItemID INT, @TransactionType CHAR(2), @LocationID INT, @propertyID INT, @DepartmentID INT =0,
 @HaveMapping BIT OUTPUT)
AS
BEGIN TRY

DECLARE @POSTGL INT, @GLCOMPCODE VARCHAR(10), @BLOCKCODEID INT, @LEVEL1 VARCHAR(10), @TID INT, @LocationCode VARCHAR(120), @GLPostType CHAR(10)
,@IsGLEnabled BIT

IF(@TransactionType = 'RI')
	SET @TransactionType = 'IN'

SELECT	@POSTGL=POSTGL, @GLCOMPCODE= C.CODE, @LEVEL1=l.Code, @LocationCode=l.Code, @GLPostType = PostGLType ,@IsGLEnabled = ISNULL(IsGLEnabled,1)
FROM	Companies  C
INNER JOIN Locations L ON L.CompanyID= c.CompanyID
where	C.CompanyID= @propertyID and L.ID= @LocationID


SELECT  @BLOCKCODEID = GLBlockID 
FROM TransactionTypes
WHERE  Code=  @TransactionType 

	--select @POSTGL , @GLCOMPCODE , @BLOCKCODEID , @LEVEL1 , @TID 

	IF  (@POSTGL= 1 AND @IsGLEnabled =1)
	BEGIN
		IF @GLPostType='HTGL'
		BEGIN

			DECLARE @XMLDATA XML, @OUTPUTREQ VARCHAR(MAX), @ItemDetailXml XML

			IF @TransactionType IN ('IN','IR','IF')
			BEGIN 

				SELECT @LEVEL1=  CODE FROM Departments
				WHERE ID= @DepartmentID
				 

			END


			IF @TransactionType IN ('GR','SR','IN','IR','DN','AA','IF','RI')
			BEGIN

				SET @XMLDATA ='
					<MYROOT>
					<HEADER>
					<GLCOMPCODE>' + @GLCOMPCODE + '</GLCOMPCODE>
					<BLOCKCODEID>'+ CONVERT(VARCHAR(MAX),@BLOCKCODEID)+'</BLOCKCODEID>
					<LEVEL1>'+@LEVEL1+ '</LEVEL1>
					<LOCATIONCODE>'+@LocationCode+'</LOCATIONCODE>
					</HEADER>
						<DETAILS>
							<ITEMDETAIL><ITEMID>'+ CONVERT(VARCHAR(MAX),@StockItemID) +'</ITEMID></ITEMDETAIL>
						</DETAILS>
					</MYROOT>'

select @XMLDATA  
--select @GLCOMPCODE GLCOMPCODE, @BLOCKCODEID BLOCKCODEID, @LEVEL1 LEVEL1, @LocationCode LocationCode, @StockItemID StockItemID
				 
				exec [eFinancials_Accounting].[dbo].GL_POSTING_INTEGRATION_VALIDATION @XMLDATA,@OUTPUTREQ OUTPUT
			 
			END 
		End
	END 

--select 1 AS HaveMapping, 'Item dosen''t have GL mapping' [Message]
SET @HaveMapping = 1
--SELECT @HaveMapping  --Commented by Nivesh 2025-02-12 for calling issue request excel upload


END TRY
BEGIN CATCH
	--select 0 AS HaveMapping, 'Item dosen''t have GL mapping' [Message]
	SET @HaveMapping = 0

	select ERROR_MESSAGE() AS ErrorMessage
	SELECT @HaveMapping  HaveMapping  --Commented by Nivesh 2025-02-12 for calling issue request excel upload


END CATCH

GO

