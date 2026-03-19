import SwiftUI

struct CategoryNameSection: View {
    @Binding var name: String

    let isDuplicateName: Bool
    let nameFieldFocus: FocusState<Bool>.Binding

    var body: some View {
        AppFormSection(title: "Name") {
            VStack(alignment: .leading, spacing: 10) {
                TextField("Category name", text: $name)
                    .focused(nameFieldFocus)
                    .textInputAutocapitalization(.words)
                    .appInputFieldStyle()

                if isDuplicateName {
                    Text("A category with this name already exists.")
                        .font(.footnote)
                        .foregroundStyle(.red)
                }
            }
            .padding(AppSpacing.contentPadding)
            .appPanelStyle()
        }
    }
}
