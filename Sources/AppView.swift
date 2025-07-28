import SwiftUI
import UIKit

struct AppView: View {
#if targetEnvironment(simulator)
    @State private var currentFile: URL? = URL(string: "/etc/passwd");
    @State private var textContent: String = """
VLAN ⟅ 2.6 ⟆

To reduce the size of broadcast domains several VLANs can be created when the number of ports
on the Layer 3 routers aren't enough to segment the LAN.
Each host within a VLAN group acts as if they were directly connected to a bus leading into the switch.
A VLAN group creates its own broadcast domain and Layer 3 routing is required to communicate with any
and all hosts outside of the VLAN. The VLAN therefore requires a network address and a hierarchical
addressing scheme.

---Benefits
• Security, segmentation of devices into subnets based on services decreases the number of vulnerabilities.
• Cost reductions in upscaling compared to purchasing physical devices.
• Better performance (Fewer broadcast domains), layer 2 traffic becomes less crowded when
multiple logical nets are used.
• Users with similar needs can share the same network configuration
which makes for a more efficient workflow.

---VLAN types 'show vlan [ brief | id [...] | name [...] | summary ]'
* Data VLAN, also referred to as user VLAN, supports data traffic and separates the net into groups of end-devices/users.
(voice and management information needs to be transferred over a different VLAN).

* Default VLAN, on boot up all the ports on a switch are put into the VLAN 1 group and therefore the switch
acts accordingly with all ports being on the same logical net. All Layer 2 traffic on unconfigured switches
therefore effectively pass through VLAN 1. The default VLAN can't be renamed or deleted.

* Native VLAN, Access ports only support traffic tagged for a certain VLAN. 802.1Q Trunk ports support the
transmission of VLAN traffic with several different tags specified for the trunk and all other untagged traffic
(lacking the 4-byte tag inserted into the Ethernet frame header) will be transferred over trunk ports using the
Native VLAN. By default set to VLAN 1 but should according to Cisco best practises be assigned to a separate VLAN.
'switchport trunk native [...]'. If you want communication on the Native VLAN then it does have to be added to the
allowed list, there might be reasons to avoid this however.

* Management VLAN, used for all switch management traffic (VLAN 1 by default), effectively the SVI is given
its own IP address in the form of the management VLAN.

* Voice VLAN, a VoIP VLAN needs to support traffic priority and rerouting around congestion, the
entire network needs to be structured in a way so that a VoIP VLAN can be created.

•• Trunk Ports ••
Point-to-Point links that connect intermediary devices with one or more associated VLANs.
The VLAN trunks are integral to expanding the VLAN with several intermediary links so that
frames can be propagated in accordance with the desired broadcast domains. Trunks don't belong to a set VLAN
but act as conduits for all in/out going traffic between different VLANs from switches as well as routers.
The trunk ports need to be configured so that they can support traffic between all the available VLAN subnets,

NOTE that Trunk ports support traffic INSIDE the VLAN, i.e. the "source" and "destination" VLAN will always be equal!

""";
#else
    @State private var currentFile: URL? = nil;
    @State private var textContent: String = "";
#endif
    @State private var editEnabled: Bool = false;
    @State private var currentError: String? = nil;

    let editorFont = Font.system(size: 17.0, design: .monospaced)
    let saveButtonFont = Font.system(size: 20.0, design: .monospaced)
    let screenWidth = UIScreen.main.bounds.size.width
    let screenHeight = UIScreen.main.bounds.size.height

    @State private var fileImporterIsPresented = false;

    var body: some View {
        VStack(alignment: .center) {
            topBarView
            contentView
        }
    }

    var topBarView: some View {
        HStack {
            if let currentFile {
                Text("\(currentFile.lastPathComponent)")
                    .font(.title2)
                    .underline()
                    .padding(.leading, 20)
                Spacer()

                Group {
                    if editEnabled {
                        Button(action: handleSave) {
                            Text(":w").font(saveButtonFont).foregroundColor(.green)
                        }
                    }
                    else {
                        Button(action: { editEnabled = true }) {
                            Text(":e").font(saveButtonFont)
                        }
                    }
                }
                .padding(.trailing, 20)
            }
        }
        .padding(.top, 20)
    }

    var contentView: some View {
        VStack(alignment: .center) {
            if currentError != nil {
                VStack {
                    Text("An error has occured")
                        .bold()
                        .font(.title2)
                        .padding(.bottom, 10)
                        .padding(.top, 10)
                    Text(currentError ?? "No description available")
                        .font(.body)
                        .foregroundColor(.red)
                }.onTapGesture {
                    currentFile = nil;
                    currentError = nil;
                }
            }
            else if currentFile != nil {
                TextEditor(text: $textContent)
                    .multilineTextAlignment(.leading)
                    .font(editorFont)
                    .autocorrectionDisabled()
                    .autocapitalization(.none)
            }
            else {
                Button(action: { fileImporterIsPresented = true }) {
                    Label("Open…", systemImage: "document.viewfinder")
                        .font(.title2)
                }
                .fileImporter(
                    isPresented: $fileImporterIsPresented,
                    allowedContentTypes: [.plainText, .text],
                    allowsMultipleSelection: false,
                    onCompletion: handleImport,
                )
            }
        }
        .padding([.leading, .trailing], 25)
    }

    private func handleSave() {
        guard let currentFile else {
            return
        }
        do {
            if !currentFile.startAccessingSecurityScopedResource() {
                currentError = "Could not gain access to: '\(currentFile.path())'"
                return
            }
            try textContent.write(to: currentFile, atomically: true, encoding: .utf8)
            editEnabled = false
        } catch {
            currentError = "Error saving file: \(error.localizedDescription)"
        }
        currentFile.stopAccessingSecurityScopedResource()
    }

    private func handleImport(result: Result<[URL], any Error>) {
        switch result {
        case .success(let files):
            files.forEach { f in
                if !f.startAccessingSecurityScopedResource() {
                    currentError = "Could not gain access to: '\(f.path())'"
                    return
                }

                do {
                    textContent = try String(contentsOf: f, encoding: .utf8)
                    currentFile = f
                }
                catch {
                    currentError = "Error reading content: \(error.localizedDescription)"
                }
                f.stopAccessingSecurityScopedResource()
            }
        case .failure(let error):
            currentError = error.localizedDescription
        }
    }
}
