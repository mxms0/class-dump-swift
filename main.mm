/* Swift Class Dumper
 *
 * Yes.
*/

#include "llvm/Object/MachO.h"
#include "llvm/Object/MachOUniversal.h"

using namespace llvm;
using namespace object;

int main(int argc, char **argv) {
	if (argc < 2) {
		printf("Not enough params :(");
		return 1;
	}

	printf("%s", argv[1]);
	std::string fileName = std::string(argv[1]);
	
	llvm::ErrorOr<std::unique_ptr<llvm::MemoryBuffer>> bufferOrError = llvm::MemoryBuffer::getFileOrSTDIN(fileName);
	
//	if (error(bufferOrError.getError(), fileName))
//		return 1;

	
	auto binOrError = createBinary(bufferOrError.get()->getMemBufferRef(), nullptr);
	
	if (!binOrError) {
		printf("Error!\r\n");
		return 1;
	}
	
	return 0;
}
