/* Swift Class Dumper
 *
 * Yes.
*/

#include <llvm/Object/ObjectFile.h>
#include <llvm/Object/MachO.h>
#include <llvm/Object/MachOUniversal.h>
#include <dlfcn.h>
#include <fstream>
#include <sstream>
#include <vector>
#include <map>
#include <iostream>
#include "Demangle.h"

using namespace llvm;
using namespace object;

struct SDClass;
struct SDClass {
	std::string name;
	std::vector<SDClass*> classes;
	std::vector<std::string> methods;
};

void createSwiftHeaderFiles(std::vector<SDClass*> classes);

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

int ctoi(char i) {
	return i - '0';
}


std::string classNameFromMangledSymbolString(const char *mangl) {
	// yes, these are all really gross. Sorry.
	
	int len = 0;
	int numLen = 0;
	bool hasNamespace = false;
	
	for (size_t i = 0; i < strlen(mangl); i++) {
		switch (mangl[i]) {
			case '_': {
				break;
			}

			default: {
				if (isdigit(mangl[i])) {
					numLen++;
					len = 10 * len;
					len += ctoi(mangl[i]);
				}
				else if (len > 0) {
					// we've already read in some digits, now it's over. reset vars too
					if (hasNamespace) {
						char *buf = (char *)malloc(len + 1);
					
						for (int j = 0; j < len; j++) {
							buf[j] = mangl[i + j];
						}
					
						buf[len] = '\0';
					
						return std::string(buf);
					}
					else {
						len = 0;
						numLen = 0;
						hasNamespace = true;
					}
				}
				break;
			}
		}
	}

	return std::string("");
}

std::string namespaceFromMangledSymbolString(const char *mangl) {
	
	int len = 0;
	int numLen = 0;
	
	for (size_t i = 0; i < strlen(mangl); i++) {
		switch (mangl[i]) {
			case '_': {
				break;
			}
				
			default: {
				if (isdigit(mangl[i])) {
					numLen++;
					len = 10 * len;
					len += ctoi(mangl[i]);
				}
				else if (len > 0) {
					// we've already read in some digits, now it's over. reset vars too
					
					char *buf = (char *)malloc(len + 1);
					
					for (int j = 0; j < len; j++) {
						buf[j] = mangl[i + j];
					}
					
					buf[len] = '\0';
					
					return std::string(buf);
				}
				break;
			}
		}
	}
	
	return std::string("");
}

void printTextForNode(swift::Demangle::NodePointer nptr) {
	//std::cout << nptr->getKind();
	if(nptr == nullptr) {
		return;
	}
	if(nptr->hasText()) {
		std::cout << ": " << nptr->getText() << "\n";
	}
	auto nitr = nptr->begin();
	while(nitr != nptr->end()) {
		printTextForNode(*nitr);
		nitr++;
	}
}

std::string signatureFromMangledSymbolString(const char *manl) {
	// remove prefix

	manl++; // remove extra '_'
	
	auto nptr = swift::Demangle::demangleSymbolAsNode(manl, strlen(manl), swift::Demangle::DemangleOptions::SimplifiedUIDemangleOptions());
	
	printTextForNode(nptr);
	
	
	std::string ret = swift::Demangle::demangleSymbolAsString(manl, swift::Demangle::DemangleOptions::SimplifiedUIDemangleOptions());
	
		printf("RET: %s\r\n", ret.c_str());
	
		return ret;
	
	return std::string("");
}

bool isSwiftSymbol(const char *mangl) {
	// check if it starts with _T
	return ((mangl[0] == '_' && mangl[1] == 'T') || (mangl[1] == '_' && mangl[2] == 'T'));
}

void parseMachOSymbols(MachOObjectFile *obj) {
//	
//	void *handle = dlopen("/Applications/Xcode.app/Contents/Developer/Toolchains/Swift_2.3.xctoolchain/usr/lib/libswiftDemangle.dylib", RTLD_NOW);
//	if (!handle) {
//		printf("[Error] probably wrong lib path. Change this dir %d", __LINE__);
//		return;
//	}
//	
//	void *dm = dlsym(handle, "swift_demangle_getDemangledName");
//	
//	size_t (*demangle)(const char *, char *, size_t) = (size_t (*)(const char *, char *, size_t))dm;

	auto symbs = obj->symbols();
	
	std::map<std::string, SDClass*> classMap;
	
	for (SymbolRef sym : symbs) {
		auto name = sym.getName();
		
		if (!name) {
			continue;
		}
		
		if (isSwiftSymbol(name->data())) {
			errs() << name->data() << "\r\n";
			
//			char buf[1024];
//			demangle(name->data() + 1, buf, 1024);
//			printf("%s\r\n", buf);
//
			std::string swiftNamespace = namespaceFromMangledSymbolString(name->data());
			std::string className = classNameFromMangledSymbolString(name->data());
			std::string methodSignature = signatureFromMangledSymbolString(name->data());
			// do stuff with these
//			printf("[%s][%s][%s]\ r\n", swiftNamespace.c_str(), className.c_str(), methodSignature.c_str());
			
			if(!classMap[className]) {
				auto classObj = new SDClass();
				classObj->name = className;
				classMap[className] = classObj;
			}
			
			classMap[className]->methods.push_back(methodSignature);
			
		}
	}
	
	std::vector<SDClass*> v;
	for(std::map<std::string,SDClass*>::iterator it = classMap.begin(); it != classMap.end(); ++it) {
		v.push_back(it->second);
	}
	createSwiftHeaderFiles(v);
}

// Returns string of 4 spaces multiplied by desired number of times
std::string indentation(int times) {
	std::stringstream ss;
	
	for (int i = 0; i < times; ++i) {
		ss << "\t";
	}
	
	return ss.str();
}

// Returns string of content for .swifth file for a class
// Function is recursive
std::string classHeaderContent(SDClass* cls, int indents) {
	std::stringstream ss;
	
	std::string indenting = indentation(indents);
	std::string indentingMeth = indentation(indents+1);
	ss << indenting << "class " << cls->name << " {\n\n";
	
	for(SDClass* cl : cls->classes) {
		ss << classHeaderContent(cl, indents+1) << "\n";
	}
	
	for (std::string str : cls->methods) {
		ss << indentingMeth << str << "\n";
	}
	
	ss << indenting << "}\n";
	return ss.str();
}

void createSwiftHeader(std::ofstream* file, SDClass* cls) {
	*file << "// \n";
	*file << "// Class dump header generated by Swift-Class-Dump\n";
	*file << "// \n\n";
	
	*file << classHeaderContent(cls, 0);
}

// Input: [Class { name:String, classes:[Class], methods:[String] }]
// create file for each class
// fill class with method signatures
//

void createSwiftHeaderFiles(std::vector<SDClass*> classes) {
	for(SDClass* cls : classes) {
		std::ofstream file;
		std::string filename = cls->name + ".swifth";
		file.open(filename);
		
		// Write to file
		createSwiftHeader(&file, cls);
		
		file.close();
	}
}

void test() {
	std::vector<SDClass*> clss;
	
	SDClass* c1 = new SDClass();
	c1->name = "c1";
	
	std::vector<std::string> c2meth;
	c2meth.push_back("c2method1");
	c2meth.push_back("c2method2");
	c2meth.push_back("c2method3");
	
	SDClass* c2 = new SDClass();
	c2->name = "c2";
	c1->classes.push_back(c2);
	c2->methods = c2meth;
	
	clss.push_back(c1);
	
	createSwiftHeaderFiles(clss);
	
	delete c1;
	delete c2;
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
