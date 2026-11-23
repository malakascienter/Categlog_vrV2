-- =============================================
-- Author:		Ravindu
-- Create date: 2026-08-05
-- Description:	Save Member (Insert or Update)
-- =============================================
CREATE   PROCEDURE [dbo].[LTY_SaveMember]
	@MemberId INT = NULL,          
	@PropertyId INT,
	@Salutation NVARCHAR(20) = NULL,
	@FirstName VARCHAR(100),
	@LastName VARCHAR(100),
	@Email NVARCHAR(200) = NULL,
	@PrimaryMobileNo NVARCHAR(20) = NULL,
	@SecondaryMobileNo NVARCHAR(20) = NULL,
	@Address VARCHAR(MAX) = NULL,
	@Birthday DATE = NULL,
	@IsActive BIT = 1,
	@TierId INT = NULL,
	@CreateBy INT
AS
BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;

	DECLARE @TransactionType VARCHAR(5) = 'MS';
	DECLARE @LocationCode    VARCHAR(20);
	DECLARE @DocNo           NVARCHAR(300);
	DECLARE @MembershipCode  VARCHAR(50);

	BEGIN TRY

		BEGIN TRANSACTION;

		IF (NULLIF(LTRIM(RTRIM(@PrimaryMobileNo)), '') IS NOT NULL
			AND EXISTS (SELECT 1 FROM [dbo].[LTY_Member]
						WHERE PrimaryMobileNo = @PrimaryMobileNo
						  AND PropertyId      = @PropertyId
						  AND MemberId        <> ISNULL(@MemberId, 0)))
		BEGIN
			RAISERROR('This mobile number is already registered to another member.', 16, 1);
		END


		IF (@MemberId IS NULL OR @MemberId = 0)
		BEGIN

			-- Location code source (same value used earlier for RegisterOutlet)
			SET @LocationCode = [dbo].[LTY_GetSettingValue](1, @PropertyId);

			---- Get Doc No ----
			SELECT @DocNo = [dbo].[FN_LTY_GetNextDocumentNumber](@PropertyId, @LocationCode, @TransactionType);
			IF (@DocNo IS NULL)
			BEGIN
				EXEC [dbo].[LTY_InsertDocumentNumber] @PropertyId, @LocationCode, @TransactionType;
				SELECT @DocNo = [dbo].[FN_LTY_GetNextDocumentNumber](@PropertyId, @LocationCode, @TransactionType);
			END

			SET @MembershipCode = CONCAT(TRIM(@TransactionType), '/', @LocationCode, '/', @DocNo);

			-- INSERT
			INSERT INTO [dbo].[LTY_Member]
			(
				MembershipCode,
				PropertyId,
				Salutation,
				FirstName,
				LastName,
				Email,
				PrimaryMobileNo,
				SecondaryMobileNo,
				Address,
				Birthday,
				IsActive,
				RegisterOutlet,
				TierId,
				CreatedBy,
				CreatedDate
			)
			VALUES
			(
				@MembershipCode,
				@PropertyId,
				@Salutation,
				@FirstName,
				@LastName,
				@Email,
				@PrimaryMobileNo,
				@SecondaryMobileNo,
				@Address,
				@Birthday,
				@IsActive,
				@LocationCode,
				@TierId,
				@CreateBy,
				GETDATE()
			);

			SET @MemberId = SCOPE_IDENTITY();

			-- Increment the counter after a successful insert
			UPDATE [dbo].[LTY_TransactionTypeWiseNextNumbers]
			SET NextNumber = NextNumber + 1
			WHERE PropertyID       = @PropertyId
			  AND LocationCode     = @LocationCode
			  AND TransactionType  = @TransactionType;
		END
		ELSE
		BEGIN
			UPDATE [dbo].[LTY_Member]
			SET
				PropertyId         = @PropertyId,
				Salutation         = @Salutation,
				FirstName          = @FirstName,
				LastName           = @LastName,
				Email              = @Email,
				PrimaryMobileNo    = @PrimaryMobileNo,
				SecondaryMobileNo  = @SecondaryMobileNo,
				Address            = @Address,
				Birthday           = @Birthday,
				IsActive           = @IsActive,
				TierId             = @TierId,
				ModifyBy           = @CreateBy,
				ModifyDate         = GETDATE()
			WHERE MemberId = @MemberId;
		END

		COMMIT TRANSACTION;

		SELECT @MemberId AS MemberId;

	END TRY
	BEGIN CATCH

		IF XACT_STATE() <> 0
			ROLLBACK TRANSACTION;

		DECLARE @ErrMsg   NVARCHAR(4000) = ERROR_MESSAGE();
		DECLARE @ErrSev   INT            = ERROR_SEVERITY();
		DECLARE @ErrState INT            = ERROR_STATE();

		RAISERROR(@ErrMsg, @ErrSev, @ErrState);

	END CATCH
END

GO

