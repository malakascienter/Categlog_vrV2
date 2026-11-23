
CREATE   PROCEDURE [dbo].[LTYM_Member_Profile_Select]
    @MemberId   INT
AS
BEGIN
    SET NOCOUNT ON;


    -- PropertyId is not part of this module's interface; it comes from the member row.
    DECLARE @PropertyId INT = (SELECT TOP (1) PropertyId FROM dbo.LTY_Member WHERE MemberId = @MemberId);
    SELECT TOP (1)
           M.MemberId,
           M.MembershipCode                            AS MembershipNo,
           M.FirstName,
           M.LastName,
           E.CallingName,
           E.TitleId,
           CAST(NULL AS NVARCHAR(100))                 AS TitleName,
           CASE WHEN M.Salutation = N'Mr' THEN 'M'
                WHEN M.Salutation IN (N'Ms', N'Mrs', N'Miss') THEN 'F'
                ELSE NULL END                          AS GenderId,
           NULLIF(M.Salutation, N'')                   AS GenderName,
           CASE WHEN M.BirthDay > '19000101'
                THEN CONVERT(VARCHAR(10), M.BirthDay, 23) END AS DOB,
           E.Anniversary,
           E.NIC,
           E.ImagePath                                 AS Image,
           E.CardNo,
           M.CreatedDate                               AS MemberSince,
           T.TierName                                  AS Tier,
           M.Email,
           M.PrimaryMobileNo                           AS ContactNo,
           E.AddressLine1,
           E.AddressLine2,
           E.City,
           E.ProvinceId,
           P.Name                                      AS ProvinceName,
           E.CountryId,
           C.CountryName                               AS CountryName
    FROM   dbo.LTY_Member AS M
    LEFT JOIN dbo.LTYM_MemberProfileExt AS E ON E.MemberId = M.MemberId
    LEFT JOIN dbo.LTY_Tier  AS T ON T.TierId = M.TierId AND T.PropertyId = M.PropertyId
    LEFT JOIN dbo.Provinces AS P ON P.ID = E.ProvinceId
    LEFT JOIN dbo.Countries AS C ON C.Id = E.CountryId
    WHERE  M.MemberId   = @MemberId
      AND  M.PropertyId = @PropertyId;
END

GO

