-- =============================================
-- Author:		Chiraj
-- Create date: 2019-2-12
-- Description:	RecipeDetails_M_Save
-- =============================================
CREATE PROCEDURE [dbo].[RecipeDetails_M_Save] 
	@RecipeCode VARCHAR(6),
	@StockItemId INT,
	@Seq INT,
	@Unit VARCHAR(3),
	@Qty DECIMAL(18,3),
	@Loc VARCHAR(3),
	@OrderType CHAR(1),
	@UserId INT,
	@Operation CHAR(1),
	@PropertyId INT
AS
BEGIN TRY
BEGIN TRANSACTION

    DECLARE @Id BIGINT
	
	SET NOCOUNT ON;	
	IF(@Operation = 'I')
	BEGIN
		IF EXISTS(SELECT 1 FROM RecipeDetails WHERE RecipeCode=@RecipeCode AND StockItemCode=@StockItemId AND PropertyId=@PropertyId)
		BEGIN
			RAISERROR('Record Already Exists.',16,1)
		END
		ELSE
		BEGIN
			INSERT INTO RecipeDetails(RecipeCode, StockItemCode, Seq, Unit, Qty, Cost, Yeild, Ord_Type, Loc, isMainItem, Type,PropertyId,IsUpload,CreatedUserId,CreatedDateTime)
			VALUES(@RecipeCode,@StockItemId,@Seq,@Unit,@Qty,0.00,0.00,@OrderType,@Loc,0,'',@PropertyId,0,@UserId,GETDATE()) 

			SET @Id = SCOPE_IDENTITY()
			-- Audit trail ----------------------------		
			EXEC HotelResWeb_AuditTail_WriteToLog 'RecipeDetails',@Id,'POS','POSRDI','I',@UserId,'','','','','',@PropertyId
			-- End of Audit trail ---------------------

		END
		
	END
	
	INSERT INTO RecipeDetailsLog(RecipeCode, StockItemCode, Seq, Unit, Qty, Cost, Yeild, Ord_Type, Loc, isMainItem, Type,PropertyId,IsUpload,CreatedUserId,CreatedDateTime)
	VALUES(@RecipeCode,@StockItemId,@Seq,@Unit,@Qty,0.00,0.00,@OrderType,@Loc,0,'',@PropertyId,0,@UserId,GETDATE()) 
	
	SELECT RD.[RecipeCode]
      ,RD.[StockItemCode]      
     -- ,U.Code AS Unit
	  ,U.Name AS Unit
      ,RD.[Qty]      
      ,RD.[PropertyId],
	  CONCAT(SH.Name,' - ',SH.StockItemCode,' - ', (CASE WHEN  RD.Ord_Type = 'R' THEN '(Eat In)' WHEN  RD.Ord_Type = 'T' THEN '(Take Away)' WHEN  RD.Ord_Type = 'B' THEN '(BOTH)' END) )  AS ItemName
  FROM [RecipeDetails] AS RD
  INNER JOIN StockItemHeaders AS SH ON SH.Id=RD.StockItemCode
  INNER JOIN Units AS U ON RD.Unit=U.Id  
  WHERE PropertyId=@PropertyId AND RD.RecipeCode=@RecipeCode AND rd.StockItemCode=@StockItemId
	--ELSE
	--BEGIN
	--END
	--SELECT rd.* ,sm.Description As ItemName 
	--FROM RecipeDetails as rd
	 --inner join StockMaster As sm On sm.ItemNo=rd.StockItemCode and sm.Location=rd.Loc
	--where rd.RecipeCode=@RecipeCode	AND rd.StockItemCode=@StockItemCode
COMMIT TRANSACTION
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION
	INSERT INTO GEN_ErrTable (ErrorNumber,ErrorSeverity,ErrorState,ErrorProcedure,ErrorLine,ErrorMessage)
    VALUES (ERROR_NUMBER(),ERROR_SEVERITY(),ERROR_STATE(),ERROR_PROCEDURE(),ERROR_LINE(),ERROR_MESSAGE())

	DECLARE  @ERRmsg VARCHAR(MAX) =ERROR_MESSAGE()
	RAISERROR(@ERRmsg,16,1)
END CATCH

GO

