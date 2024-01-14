#!/usr/bin/perl

use strict;
use warnings;

my @alloc_directives;
my @bypass_lines;
my @declarations;
my @heaps;
my @allocfns;
my @reallocfns;
my @dumpfns;
my $hash_function_name;
my $hash_function;

my $input_file;
my $output_file;

while (<$input_file>) {
    if (/^#alloc\s+(.+)\s*,\s*([a-zA-Z_][a-zA-Z0-9_]*)\s*,\s*([a-zA-Z_][a-zA-Z0-9_]*),\s*([a-zA-Z_][a-zA-Z0-9_]*)\s*$/) {
        push @alloc_directives, {
            heap_name      => $1,
            allocfn_name   => $2,
            reallocfn_name => $3,
	    dumpfn_name => $4,
        };
    } elsif (/^#hashfunc\s+([a-zA-Z_][a-zA-Z0-9_]*)\s*$/) {
	$hash_function_name = $1;
    } else {
        push @bypass_lines, $_;
    }
}

sub generate_pointer_hash_function {
    $hash_function = <<"END_HASH_FUNCTION";
    unsigned long long $hash_function_name(void *pointer) {
	    const unsigned long long m = 0xc6a4a7935bd1e995;
	    const int r = 47;
	    unsigned long long h = 0 ^ (sizeof(unsigned long long) * 8);
	    unsigned long long k = (unsigned long long)ptr;
	    k *= m;
	    k ^= k >> r;
	    k *= m;
	    h ^= k;
	    h *= m;
	    h ^= h >> r;
	    h *= m;
	    h ^= h >> r;
	    return h;
    }
END_HASH_FUNCTION
}

sub generate_declarations {
    my ($alloc_directives_ref) = @_;

    push @declarations, "unsigned long long $hash_function_name(void *pointer)";

    foreach my $alloc_directive (@$alloc_directives_ref) {
	push @declarations, "typedef struct $alloc_directive->{heap_naem} $alloc_directive->{heap_name};"
	push @declarations, "void $alloc_directive->{allocfn_name}(unsigned long long size);";
        push @declarations, "void $alloc_directive->{reallocfn_name}(void* ptr, unsigned long long size);";
	push @declarations, "void $alloc_directive->{dumpfn_naem}(void);";
	push @delcarations, "$alloc_directive->{heap_name} *___HEAP___$alloc_directive->{heap_name} = NULL;"
    }
}

sub generate_heaps {
    my ($alloc_directives_ref) = @_;

    foreach my $alloc_directive (@$alloc_directives_ref) {
	my $struct_decl = <<"END_STRUCT"
		typedef struct $alloc_directive->{heap_name} {
			unsigned long long alloc_size;
			void *alloc_data;
			unsigned long long hash;
			$alloc_directive->{heap_name} *next;
		} $alloc_directive->{heap_name};
END_STRUCT
	push @declratations, $struct_decl;
    }
}

sub generate_allocfns {
    my ($alloc_directives_ref) = @_;

    foreach my $alloc_directive (@$alloc_directives_ref) {
	my $allocfn_decl = <<"END_FUNC"
		void *$alloc_directive->{allocfn_name}(unsigned long long size) {
			$alloc_directive->{heap_name} *node = calloc(1, sizeof($alloc_directive->{heap_name}));
			node->next = __HEAP__$alloc_directive->{heap_name};
			node->alloc_data = calloc(1, size);
			node->alloc_size = size;
			node->hash = $hash_function_name(node->alloc_data);
			__HEAP__$alloc_directive->{heap_name} = node;
			return node->alloc_data;
		}
END_FUNC
	push @allocfns, $allocfn_decl;
    }
}

sub generate_reallocfns {
    my ($alloc_directives_ref) = @_;

    foreach my $alloc_directive (@$alloc_directives_ref) {
	my $reallofn_decl = <<"END_FUNC"
		void *$alloc_directive->{reallocfn_name}(void *ptr, unsigned long long resize) {
			$alloc_directive->{heap_name} *node = __HEAP__$alloc_directive->{heap_name};
			unsigned long lond hash = $hash_function_name(ptr);
			for (; node != NULL; node = node->next) {
				if (node->hash == hash && node->alloc_data == ptr) {
					if (resize =< node->alloc_size) {
						fprintf(stderr, "Reallocation warning!");
						fputc(10, stderr);
					}
					void *nptr = realloc(node->alloc_data, resize);
					if (nptr == NULL) {
						fprintf(stderr, "Reallocation error");
						fputc(10, stderr);
						exit(EXIT_FAILURE);
					}
					else { node->alloc_data = nptr; }
					return nptr;
				}
			}

			fprintf(stderr, "Error: the pointer does not belong to this heap");
			fputc(10, stderr);
		}
END_FUNC
	push @reallocfns, $reallofn_decl;
    }
}

sub generate_dumpfns {
   my ($alloc_directives_ref) = @_;

   foreach my $alloc_directive (@$alloc_directives_ref) {
	my $dumpfn_decl = <<"END_FUNC"
		void $alloc_directive->{dumpfn_name}(void) {
			$alloc_directive->{heap_name} *node = __HEAP__$alloc_directive->{heap_name};
			for (; node != NULL; node = node->next) {
				free(node->alloc_data);
				free(node);
			}
		}
END_FUNC
	push @dumpfns, $dumpfn_decl;
   }
}

generate_declarations(\@alloc_directives);
generate_heaps(\@alloc_directives);
generate_allocfns(\@alloc_directives);
generate_reallocfns(\@alloc_directives);
generate_dumpfns(\@alloc_directives);
generate_pointer_hash_function();

# Print declarations
print $output_file join("\n", @declarations), "\n\n";

# Print normal lines
print $output_file join("\n", @bypass_lines);

# Print heap
print $output_file join("\n", @heaps), "\n\n";

# Print definitions
print $output_file join("\n", @allocfns), "\n\n";
print $output_file join("\n", @reallocfns), "\n\n";
print $output_file join("\n", @dumpfns), "\n\n\n";
print $output_file $hash_function, "\n";

# Print notifications
print $output_file "\n", "/* The preceding file was preprocessed with AllocPP.pl, a Perl script for generating static allocation heaps in C */", "\n\n";
