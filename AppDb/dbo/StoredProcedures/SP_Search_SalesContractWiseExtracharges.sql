CREATE PROCEDURE [dbo].[SP_Search_SalesContractWiseExtracharges]

@from INT,
	@to INT,
	@search VARCHAR(20),
	@sortType INT,
	@sortColumn INT,
	@totalRecordCount INT OUTPUT,
	@status INT OUTPUT, 
	@message VARCHAR(20) OUTPUT
AS
DECLARE @statusIN[int]
	SET @statusIN = 0;
	SET  @message = ''

BEGIN
BEGIN TRY
BEGIN TRANSACTION

SET @search = LTRIM(RTRIM(@search))

	IF(@sortColumn = 0 AND @sortType = 0)
	BEGIN
		IF(@search IS NULL OR @search = '')
		BEGIN 
			SELECT @totalRecordCount = COUNT(*) FROM SalesContractWiseExtracharges
	
			SELECT * FROM( SELECT * , (ROW_NUMBER() OVER(ORDER BY ID ASC)) AS RowNum FROM dbo.SalesContractWiseExtracharges  WHERE (Id LIKE '%' + @search + '%' OR  ChargeRate LIKE '%' + @search + '%' OR ItemPrice LIKE '%' + @search + '%'
			OR TotalChargeAmount LIKE '%' + @search + '%' OR ChargeAmountPerItem LIKE '%' + @search + '%') ) 
			AS InvDets
			WHERE RowNum BETWEEN @from AND @to 
			ORDER BY Id ASC 
		END

	ELSE
        BEGIN

		SELECT @totalRecordCount = COUNT(*) FROM SalesContractWiseExtracharges WHERE (SalesContractWiseExtracharges.Id LIKE '%' + @search + '%' OR SalesContractWiseExtracharges.ChargeRate LIKE '%' + @search + '%' OR SalesContractWiseExtracharges.ItemPrice LIKE '%' + @search + '%'
		OR SalesContractWiseExtracharges.TotalChargeAmount LIKE '%' + @search + '%' OR SalesContractWiseExtracharges.ChargeAmountPerItem LIKE '%' + @search + '%') 

		SELECT * FROM ( SELECT * , (ROW_NUMBER() OVER(ORDER BY Id ASC
		)) AS RowNum FROM SalesContractWiseExtracharges 
				WHERE id LIKE '%' + @search + '%' OR ChargeRate LIKE '%' + @search + '%' OR ItemPrice LIKE '%' + @search + '%' OR TotalChargeAmount LIKE '%' + @search + '%' OR ChargeAmountPerItem LIKE '%' + @search + '%') 
				AS InvDets 
					
					WHERE InvDets.RowNum BETWEEN @from AND @to 
					ORDER BY InvDets.Id ASC
		END 
	END

	ELSE
	BEGIN

	IF(@search IS NULL OR @search = '')
		BEGIN 
			SELECT @totalRecordCount = COUNT(*) FROM SalesContractWiseExtracharges
	
			SELECT * FROM( SELECT * , (ROW_NUMBER() OVER(ORDER BY 
			(CASE 
					WHEN @sortColumn = 0 AND @sortType = 1 THEN Id
					WHEN @sortColumn = 1 AND @sortType = 1 THEN ChargeRate
					WHEN @sortColumn = 2 AND @sortType = 1 THEN ItemPrice
					WHEN @sortColumn = 3 AND @sortType = 1 THEN TotalChargeAmount
					WHEN @sortColumn = 4 AND @sortType = 1 THEN ChargeAmountPerItem END) ASC,

					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 0 THEN Id
					WHEN @sortColumn = 1 AND @sortType = 0 THEN ChargeRate
					WHEN @sortColumn = 2 AND @sortType = 0 THEN ItemPrice
					WHEN @sortColumn = 3 AND @sortType = 0 THEN TotalChargeAmount
					WHEN @sortColumn = 4 AND @sortType = 0 THEN ChargeAmountPerItem END) DESC

			)) AS RowNum FROM SalesContractWiseExtracharges  WHERE (Id LIKE '%' + @search + '%' OR ChargeRate LIKE '%' + @search + '%' OR ItemPrice LIKE '%' + @search + '%'
			OR TotalChargeAmount LIKE '%' + @search + '%' OR ChargeAmountPerItem LIKE '%' + @search + '%' )) 
			AS InvDets

			WHERE RowNum BETWEEN @from AND @to 
				
				ORDER BY 
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 1 THEN Id
					WHEN @sortColumn = 1 AND @sortType = 1 THEN ChargeRate
					WHEN @sortColumn = 2 AND @sortType = 1 THEN ItemPrice
					WHEN @sortColumn = 3 AND @sortType = 1 THEN TotalChargeAmount
					WHEN @sortColumn = 4 AND @sortType = 1 THEN ChargeAmountPerItem END) ASC,

					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 0 THEN Id
					WHEN @sortColumn = 1 AND @sortType = 0 THEN ChargeRate
					WHEN @sortColumn = 2 AND @sortType = 0 THEN ItemPrice
					WHEN @sortColumn = 3 AND @sortType = 0 THEN TotalChargeAmount
					WHEN @sortColumn = 4 AND @sortType = 0 THEN ChargeAmountPerItem END) DESC
		END

ELSE
        BEGIN

		SELECT @totalRecordCount = COUNT(*) FROM SalesContractWiseExtracharges WHERE (SalesContractWiseExtracharges.id LIKE '%' + @search + '%' OR SalesContractWiseExtracharges.ChargeRate LIKE '%' + @search + '%' 
		OR SalesContractWiseExtracharges.ItemPrice LIKE '%' + @search + '%' OR SalesContractWiseExtracharges.TotalChargeAmount LIKE '%' + @search + '%' OR SalesContractWiseExtracharges.ChargeAmountPerItem LIKE '%' + @search + '%') 

		SELECT * FROM ( SELECT * , (ROW_NUMBER() OVER(ORDER BY 
		(CASE 
					WHEN @sortColumn = 0 AND @sortType = 1 THEN Id
					WHEN @sortColumn = 1 AND @sortType = 1 THEN ChargeRate
					WHEN @sortColumn = 2 AND @sortType = 1 THEN ItemPrice
					WHEN @sortColumn = 3 AND @sortType = 1 THEN TotalChargeAmount
					WHEN @sortColumn = 4 AND @sortType = 1 THEN ChargeAmountPerItem END) ASC,

					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 0 THEN Id
					WHEN @sortColumn = 1 AND @sortType = 0 THEN ChargeRate
					WHEN @sortColumn = 2 AND @sortType = 0 THEN ItemPrice
					WHEN @sortColumn = 3 AND @sortType = 0 THEN TotalChargeAmount
					WHEN @sortColumn = 4 AND @sortType = 0 THEN ChargeAmountPerItem END) DESC
		
		)) AS RowNum FROM SalesContractWiseExtracharges 
				WHERE id LIKE '%' + @search + '%' OR ChargeRate LIKE '%' + @search + '%' OR ItemPrice LIKE '%' + @search + '%' OR TotalChargeAmount LIKE '%' + @search + '%' OR ChargeAmountPerItem LIKE '%' + @search + '%') 
				AS InvDets 
					
					WHERE InvDets.RowNum BETWEEN @from AND @to 
					ORDER BY 
					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 1 THEN Id
					WHEN @sortColumn = 1 AND @sortType = 1 THEN ChargeRate
					WHEN @sortColumn = 2 AND @sortType = 1 THEN ItemPrice
					WHEN @sortColumn = 3 AND @sortType = 1 THEN TotalChargeAmount
					WHEN @sortColumn = 4 AND @sortType = 1 THEN ChargeAmountPerItem END) ASC,

					(CASE 
					WHEN @sortColumn = 0 AND @sortType = 0 THEN Id
					WHEN @sortColumn = 1 AND @sortType = 0 THEN ChargeRate
					WHEN @sortColumn = 2 AND @sortType = 0 THEN ItemPrice
					WHEN @sortColumn = 3 AND @sortType = 0 THEN TotalChargeAmount
					WHEN @sortColumn = 4 AND @sortType = 0 THEN ChargeAmountPerItem END) DESC
		END 

		END 
		COMMIT TRAN -- Transaction Success!
	SET @status = @statusIN;
END TRY 
BEGIN CATCH
	SET @status = -1;
	SET @message = CAST(ERROR_NUMBER() AS VARCHAR(10)) + ' - ' + ERROR_MESSAGE() + ' - On Line ' + CAST(ERROR_LINE() AS VARCHAR(10))	
END CATCH;
END

GO

