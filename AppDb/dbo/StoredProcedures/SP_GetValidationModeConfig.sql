CREATE   PROCEDURE [dbo].[SP_GetValidationModeConfig]
    @PropertyId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT vm.Id,
           LTRIM(RTRIM(vm.Code))           AS Code,
           vm.Description,
           vm.IsValue,
           vm.IsPercentage,
           ISNULL(st.AutoApplyDefault, 0)  AS AutoApplyDefault,
           ISNULL(st.SaveCodeInHeader, 1)  AS SaveCodeInHeader,
           st.HintText,
           (SELECT t.SectionCode      AS Section,
                   t.Title,
                   t.Icon,
                   t.Width,
                   t.ControlType,
                   t.Placeholder,
                   t.AllowAddAll,
                   t.MaxRows,
                   t.ValueMaxLength,
                   t.ValueFormat,
                   s.IsRequired       AS Required,
                   s.RequiredMessage  AS Message,
                   (SELECT f.FieldCode      AS Field,
                           f.Label,
                           f.Scope,
                           f.InputType,
                           f.IsRequired     AS Required,
                           f.MinValue,
                           f.MaxValue,
                           f.MaxLength,
                           f.InputFormat,
                           f.DefaultValue,
                           f.EnableWhenAnyOf,
                           f.Width
                      FROM dbo.INV_DiscountSectionFields f
                     WHERE f.SectionTypeId = t.Id
                       AND f.IsActive = 1
                     ORDER BY f.SortOrder
                       FOR JSON PATH) AS Fields
              FROM dbo.INV_ValidationModeSections s
              JOIN dbo.INV_DiscountSectionTypes t ON t.Id = s.SectionTypeId AND t.IsActive = 1
             WHERE s.ValidationModeId = vm.Id
             ORDER BY s.SortOrder
               FOR JSON PATH) AS SectionsJson
      FROM dbo.ValidationModes vm
      LEFT JOIN dbo.INV_ValidationModeSettings st ON st.ValidationModeId = vm.Id
     WHERE vm.PropertyId = @PropertyId
       AND ISNULL(st.IsActive, 1) = 1 AND VM.IsActive = 1
     ORDER BY ISNULL(st.SortOrder, 0), vm.Description;
END

GO

