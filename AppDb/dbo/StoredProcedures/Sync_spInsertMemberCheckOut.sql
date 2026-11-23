



CREATE PROCEDURE [dbo].[Sync_spInsertMemberCheckOut]
@MemberId INT,
@CheckedInDateTime DATETIME,
@CheckedOutDateTime DATETIME


AS
SET DATEFORMAT DMY
	INSERT INTO MemberCheckedOut (MemberId, CheckedInDateTime, CheckedOutDateTime)
	VALUES	(@MemberId, @CheckedInDateTime, @CheckedOutDateTime)

GO

