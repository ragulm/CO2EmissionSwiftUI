import SwiftUI

struct CompletedRoutesView: View {
    @EnvironmentObject var viewModel: CommuteViewModel
    
    var body: some View {
        NavigationView {
            if viewModel.completedRoutes.isEmpty {
                VStack(spacing: 24) {
                    Image(systemName: "map")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.gray.opacity(0.5))
                    Text("No routes completed yet")
                        .font(.title3)
                        .foregroundColor(.gray)
                    Text("Complete a route to see it here!")
                        .font(.body)
                        .foregroundColor(.gray)
                }
                .padding()
                .navigationTitle("Completed Routes")
            } else {
                List {
                    Section(header: Text("Completed Routes")) {
                        ForEach(viewModel.completedRoutes.reversed()) { route in
                            CompletedRouteRowView(route: route)
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
                .navigationTitle("Completed Routes")
            }
        }
    }
}

#Preview {
    CompletedRoutesView().environmentObject(CommuteViewModel())
}
