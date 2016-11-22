/* Swift Class Dumper
 *
 * Yes.
*/

#include "llvm/Object/MachO.h"
#include "llvm/Object/MachOUniversal.h"

int main(int argc, char **argv) {
	if (argc < 2) {
		printf("Not enough params :(");
		return 1;
	}

	printf("%s", argv[1]);
	std::string fileName = std::string(argv[1]);
	
	llvm::ErrorOr<std::unique_ptr<llvm::MemoryBuffer>> BufferOrErr = llvm::MemoryBuffer::getFileOrSTDIN(fileName);
	
	

	return 0;
}
