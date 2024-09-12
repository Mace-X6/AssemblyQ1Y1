if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <file_name>"
    exit 1
fi

file_name=$1

#thanks chatgpt

gcc -g -o "$file_name" -no-pie "$file_name.s"
gdb ./"$file_name"
