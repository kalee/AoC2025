#!/usr/bin/perl
use strict;
use warnings;

# ============================================================================
# GRID CREATION & POPULATION
# ============================================================================

# Initialize a new grid with metadata
# Returns: ($grid_ref, $meta_ref)
sub new_grid {
    my %grid;
    my %meta = (
        max_row => -1,
        max_col => -1,
        min_row => undef,
        min_col => undef
    );
    return (\%grid, \%meta);
}

# Set a cell value and update metadata
# Pass: ($grid_ref, $meta_ref, $row, $col, $value)
sub set_cell {
    my ($grid, $meta, $r, $c, $val) = @_;
    $grid->{"$r,$c"} = $val;
    
    # Update dimensions dynamically
    $meta->{max_row} = $r if !defined $meta->{max_row} || $r > $meta->{max_row};
    $meta->{max_col} = $c if !defined $meta->{max_col} || $c > $meta->{max_col};
    $meta->{min_row} = $r if !defined $meta->{min_row} || $r < $meta->{min_row};
    $meta->{min_col} = $c if !defined $meta->{min_col} || $c < $meta->{min_col};
}

# Get a cell value with default fallback
# Pass: ($grid_ref, $row, $col, $default)
sub get_cell {
    my ($grid, $r, $c, $default) = @_;
    $default //= '.';  # Default to '.' if not specified
    return $grid->{"$r,$c"} // $default;
}

# Check if a cell exists
# Pass: ($grid_ref, $row, $col)
sub has_cell {
    my ($grid, $r, $c) = @_;
    return exists $grid->{"$r,$c"};
}

# Populate grid from array of strings (common AoC format)
# Pass: ($grid_ref, $meta_ref, \@lines)
sub populate_from_lines {
    my ($grid, $meta, $lines) = @_;
    
    for my $r (0 .. $#{$lines}) {
        my @chars = split //, $lines->[$r];
        for my $c (0 .. $#chars) {
            set_cell($grid, $meta, $r, $c, $chars[$c]);
        }
    }
}

# ============================================================================
# GRID TRANSFORMATIONS
# ============================================================================

# Rotate counter-clockwise (in-place)
# Formula: [row, col] -> [max_col - col, row]
# Pass: ($grid_ref, $meta_ref)
sub rotate_ccw {
    my ($grid, $meta) = @_;
    my %new_grid;
    my $max_col = $meta->{max_col};
    
    foreach my $key (keys %$grid) {
        my ($r, $c) = split /,/, $key;
        my $new_r = $max_col - $c;
        my $new_c = $r;
        $new_grid{"$new_r,$new_c"} = $grid->{$key};
    }
    
    # Update metadata: dimensions swap
    ($meta->{max_row}, $meta->{max_col}) = ($meta->{max_col}, $meta->{max_row});
    ($meta->{min_row}, $meta->{min_col}) = ($meta->{min_col}, $meta->{min_row});
    %$grid = %new_grid;
}

# Rotate clockwise (in-place)
# Formula: [row, col] -> [col, max_row - row]
# Pass: ($grid_ref, $meta_ref)
sub rotate_cw {
    my ($grid, $meta) = @_;
    my %new_grid;
    my $max_row = $meta->{max_row};
    
    foreach my $key (keys %$grid) {
        my ($r, $c) = split /,/, $key;
        my $new_r = $c;
        my $new_c = $max_row - $r;
        $new_grid{"$new_r,$new_c"} = $grid->{$key};
    }
    
    # Update metadata: dimensions swap
    ($meta->{max_row}, $meta->{max_col}) = ($meta->{max_col}, $meta->{max_row});
    ($meta->{min_row}, $meta->{min_col}) = ($meta->{min_col}, $meta->{min_row});
    %$grid = %new_grid;
}

# Flip horizontally (in-place)
# Formula: [row, col] -> [row, max_col - col]
# Pass: ($grid_ref, $meta_ref)
sub flip_horizontal {
    my ($grid, $meta) = @_;
    my %new_grid;
    my $max_col = $meta->{max_col};
    
    foreach my $key (keys %$grid) {
        my ($r, $c) = split /,/, $key;
        my $new_r = $r;
        my $new_c = $max_col - $c;
        $new_grid{"$new_r,$new_c"} = $grid->{$key};
    }
    
    %$grid = %new_grid;
}

# Flip vertically (in-place)
# Formula: [row, col] -> [max_row - row, col]
# Pass: ($grid_ref, $meta_ref)
sub flip_vertical {
    my ($grid, $meta) = @_;
    my %new_grid;
    my $max_row = $meta->{max_row};
    
    foreach my $key (keys %$grid) {
        my ($r, $c) = split /,/, $key;
        my $new_r = $max_row - $r;
        my $new_c = $c;
        $new_grid{"$new_r,$new_c"} = $grid->{$key};
    }
    
    %$grid = %new_grid;
}

# ============================================================================
# GRID ANALYSIS
# ============================================================================

# Get all neighbors (4-directional: up, down, left, right)
# Pass: ($grid_ref, $row, $col)
# Returns: array of [$r, $c, $value] for existing neighbors
sub get_neighbors_4 {
    my ($grid, $r, $c) = @_;
    my @neighbors;
    my @directions = ([-1, 0], [1, 0], [0, -1], [0, 1]);
    
    foreach my $dir (@directions) {
        my ($dr, $dc) = @$dir;
        my $nr = $r + $dr;
        my $nc = $c + $dc;
        if (has_cell($grid, $nr, $nc)) {
            push @neighbors, [$nr, $nc, $grid->{"$nr,$nc"}];
        }
    }
    
    return @neighbors;
}

# Get all neighbors (8-directional: includes diagonals)
# Pass: ($grid_ref, $row, $col)
# Returns: array of [$r, $c, $value] for existing neighbors
sub get_neighbors_8 {
    my ($grid, $r, $c) = @_;
    my @neighbors;
    my @directions = (
        [-1, -1], [-1, 0], [-1, 1],
        [0, -1],           [0, 1],
        [1, -1],  [1, 0],  [1, 1]
    );
    
    foreach my $dir (@directions) {
        my ($dr, $dc) = @$dir;
        my $nr = $r + $dr;
        my $nc = $c + $dc;
        if (has_cell($grid, $nr, $nc)) {
            push @neighbors, [$nr, $nc, $grid->{"$nr,$nc"}];
        }
    }
    
    return @neighbors;
}

# Count cells matching a condition
# Pass: ($grid_ref, $value_to_match)
sub count_cells {
    my ($grid, $match) = @_;
    my $count = 0;
    
    foreach my $val (values %$grid) {
        $count++ if $val eq $match;
    }
    
    return $count;
}

# Find all cells matching a value
# Pass: ($grid_ref, $value_to_find)
# Returns: array of [$r, $c] coordinates
sub find_cells {
    my ($grid, $match) = @_;
    my @found;
    
    foreach my $key (keys %$grid) {
        if ($grid->{$key} eq $match) {
            my ($r, $c) = split /,/, $key;
            push @found, [$r, $c];
        }
    }
    
    return @found;
}


# Find first cell matching a value
# Pass: ($grid_ref, $value_to_find)
# Returns: [$r, $c] coordinate of match
sub find_first_cell {
    my ($grid, $match) = @_;
    
    for my $key (keys %$grid) {
        if ($grid->{$key} eq $match) {
            my ($r, $c) = split /,/, $key;
            return [$r, $c];
        }
    }
    return;
}



# ============================================================================
# GRID OUTPUT
# ============================================================================

# Print the grid
# Pass: ($grid_ref, $meta_ref, $default_char)
sub print_grid {
    my ($grid, $meta, $default) = @_;
    $default //= '.';
    
    for my $r ($meta->{min_row} // 0 .. $meta->{max_row}) {
        for my $c ($meta->{min_col} // 0 .. $meta->{max_col}) {
            print get_cell($grid, $r, $c, $default) . " ";
        }
        print "\n";
    }
}

# Get grid as string (useful for hashing/comparison)
# Pass: ($grid_ref, $meta_ref, $default_char)
sub grid_to_string {
    my ($grid, $meta, $default) = @_;
    $default //= '.';
    my $str = '';
    
    for my $r ($meta->{min_row} // 0 .. $meta->{max_row}) {
        for my $c ($meta->{min_col} // 0 .. $meta->{max_col}) {
            $str .= get_cell($grid, $r, $c, $default);
        }
        $str .= "\n";
    }
    
    return $str;
}

# Clone a grid (deep copy)
# Pass: ($grid_ref, $meta_ref)
# Returns: ($new_grid_ref, $new_meta_ref)
sub clone_grid {
    my ($grid, $meta) = @_;
    my %new_grid = %$grid;
    my %new_meta = %$meta;
    return (\%new_grid, \%new_meta);
}

=comment

# ============================================================================
# EXAMPLE USAGE
# ============================================================================

# Create and populate a grid
my ($grid, $meta) = new_grid();

my @input = (
    "ABC",
    "DEF",
    "GHI"
);

populate_from_lines($grid, $meta, \@input);

print "Original Grid:\n";
print_grid($grid, $meta);

print "\nRotated Clockwise:\n";
rotate_cw($grid, $meta);
print_grid($grid, $meta);

print "\nRotated Counter-Clockwise (back to original):\n";
rotate_ccw($grid, $meta);
print_grid($grid, $meta);

print "\nFlipped Horizontally:\n";
flip_horizontal($grid, $meta);
print_grid($grid, $meta);

print "\nFind all 'E' cells:\n";
my @e_cells = find_cells($grid, 'E');
foreach my $cell (@e_cells) {
    print "Found 'E' at [$cell->[0], $cell->[1]]\n";
}

print "\nNeighbors of center cell (1,1):\n";
my @neighbors = get_neighbors_4($grid, 1, 1);
foreach my $n (@neighbors) {
    print "  [$n->[0], $n->[1]] = $n->[2]\n";
}
=cut

1;  # Important: return true value at end of library file
