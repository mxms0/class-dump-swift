/* Swift Class Dumper
 *
 * Yes.
*/

#include "llvm/Object/ObjectFile.h"
#include "llvm/Object/MachO.h"
#include "llvm/Object/MachOUniversal.h"

using namespace llvm;
using namespace object;

void printMachOInformation(MachOObjectFile *obj) {
	// TODO: clean up this mess and finish it. Should just print relevant header-infos
	
	/* TODO: print should look like this:
	 * CPUType: 0x1000007 (x86-64)
	 * CPUType: 0x7 (x86)
	 * CPUType: 0x12 (Arm)
	 * CPUType: 0x1000012 (Arm64)
	 * et al
	 */
	
	MachO::mach_header header;
	MachO::mach_header_64 header64;
	
	Triple T;
	if (obj->is64Bit()) {
		printf("64bit!\r\n");
		if (header64.cpusubtype | llvm::MachO::CPU_TYPE_X86) {
			printf("X86 found\r\n");
		}
		if (header64.cpusubtype | llvm::MachO::CPU_ARCH_ABI64) {
			// confirms 64bit
		}
	
		
		header64 = obj->MachOObjectFile::getHeader64();
		T = MachOObjectFile::getArchTriple(header64.cputype, header64.cpusubtype);
		
			printf("CPUType: 0x%x\r\nCPUSubtype: 0x%x", header64.cputype, header.cpusubtype);
	}
	else {
		printf("32bit!\r\n");
		header = obj->MachOObjectFile::getHeader();
		T = MachOObjectFile::getArchTriple(header.cputype, header64.cpusubtype);
		
		printf("CPUType: 0x%x\r\nCPUSubtype: 0x%x", header64.cputype, header.cpusubtype);
	}
}

std::string nameFromMangledSymbolString(std::string mangl) {
	// implement
	return std::string("");
}

std::string signatureFromMangledSymbolString(std::string manl) {
	// implement
	return std::string("");
}

bool isSwiftSymbol(std::string mangl) {
	// check if it starts with _T
	return false;
}

void parseMachOSymbols(MachOObjectFile *obj) {
	auto symbs = obj->symbols();
	
	for (SymbolRef sym : symbs) {
		auto name = sym.getName();
		
		if (!name) {
			continue;
		}
		
		errs() << name->data() << "\r\n";
		
		if (isSwiftSymbol(name->str()) {
			// should check type to see if its in the right seg of the binary
			// otherwise pass to function to un-mangle and add to map
			std::string className = nameFromMangledSymbolString(name->str());
			std::string methodSignature = signatureFromMangledSymbolString(name->str());
			// do stuff with these
		}
	}
	
}

int main(int argc, char **argv) {
	if (argc < 2) {
		printf("Not enough params :(");
		return 1;
	}

	std::string fileName = std::string(argv[1]);
	
	llvm::ErrorOr<std::unique_ptr<llvm::MemoryBuffer>> bufferOrError = llvm::MemoryBuffer::getFileOrSTDIN(fileName);
	
//	if (error(bufferOrError.getError(), fileName))
//		return 1;

	
	auto binOrError = createBinary(bufferOrError.get()->getMemBufferRef(), nullptr);
	
	if (!binOrError) {
		printf("Error!\r\n");
		return 1;
	}
	
	Binary &bin = *binOrError.get();
	
	if (SymbolicFile *symbol = dyn_cast<SymbolicFile>(&bin)) {
		// ensure this is a mach-o
		if (MachOObjectFile *macho = dyn_cast<MachOObjectFile>(symbol)) {
			printMachOInformation(macho);
			parseMachOSymbols(macho);
			
		}
		else {
			printf("What is this?\r\n");
			return 3;
		}
	}
	
	else if (MachOUniversalBinary *macho = dyn_cast<MachOUniversalBinary>(&bin)) {
		printf("Found mach-o universal %p\r\n", (void *)macho);
	}
	
	else if (Archive *archiv = dyn_cast<Archive>(&bin)) {
		printf("Found archive %p\r\n", (void *)archiv);
	}
	
	else {
		printf("This is not a mach-o! :(\r\n");
	}
	
	return 0;
}
