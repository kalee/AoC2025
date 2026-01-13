#!/usr/bin/perl
use strict;
use warnings;
use List::Util qw(min);

# ============================================================================
# GRAPH CREATION & MANAGEMENT
# ============================================================================

# Create a new graph
# Returns: $graph_ref = { nodes => {}, edges => {}, weighted => 0/1 }
sub new_graph {
    my ($weighted) = @_;
    $weighted //= 0;
    
    return {
        nodes => {},      # node_id => 1 (exists)
        edges => {},      # "from,to" => weight (or 1 for unweighted)
        adjacency => {},  # from => [to1, to2, ...]
        weighted => $weighted
    };
}

# Add a node to the graph
# Pass: ($graph_ref, $node_id)
sub add_node {
    my ($graph, $node) = @_;
    $graph->{nodes}{$node} = 1;
    $graph->{adjacency}{$node} //= [];
}

# Add an edge to the graph
# Pass: ($graph_ref, $from, $to, $weight)
sub add_edge {
    my ($graph, $from, $to, $weight) = @_;
    $weight //= 1;
    
    add_node($graph, $from);
    add_node($graph, $to);
    
    $graph->{edges}{"$from,$to"} = $weight;
    push @{$graph->{adjacency}{$from}}, $to;
}

# Add bidirectional edge (for undirected graphs)
# Pass: ($graph_ref, $node1, $node2, $weight)
sub add_edge_bidirectional {
    my ($graph, $n1, $n2, $weight) = @_;
    add_edge($graph, $n1, $n2, $weight);
    add_edge($graph, $n2, $n1, $weight);
}

# Get edge weight
# Pass: ($graph_ref, $from, $to)
sub get_edge_weight {
    my ($graph, $from, $to) = @_;
    return $graph->{edges}{"$from,$to"};
}

# Get neighbors of a node
# Pass: ($graph_ref, $node)
sub get_neighbors {
    my ($graph, $node) = @_;
    return @{$graph->{adjacency}{$node} // []};
}

# ============================================================================
# CYCLE DETECTION
# ============================================================================

# Detect if graph has cycles using DFS
# Pass: ($graph_ref)
# Returns: (has_cycle, \@cycle_nodes) or (0, undef)
sub detect_cycle_dfs {
    my ($graph) = @_;
    my %visited;
    my %rec_stack;
    my @cycle;
    
    sub _dfs_cycle {
        my ($node, $graph, $visited, $rec_stack, $cycle, $parent) = @_;
        
        $visited->{$node} = 1;
        $rec_stack->{$node} = 1;
        push @$parent, $node;
        
        foreach my $neighbor (get_neighbors($graph, $node)) {
            if (!$visited->{$neighbor}) {
                if (_dfs_cycle($neighbor, $graph, $visited, $rec_stack, $cycle, $parent)) {
                    return 1;
                }
            } elsif ($rec_stack->{$neighbor}) {
                # Found cycle - extract it
                my $idx = 0;
                $idx++ until $parent->[$idx] eq $neighbor || $idx >= @$parent;
                @$cycle = @$parent[$idx .. $#$parent];
                return 1;
            }
        }
        
        $rec_stack->{$node} = 0;
        pop @$parent;
        return 0;
    }
    
    foreach my $node (keys %{$graph->{nodes}}) {
        if (!$visited{$node}) {
            my @parent;
            if (_dfs_cycle($node, $graph, \%visited, \%rec_stack, \@cycle, \@parent)) {
                return (1, \@cycle);
            }
        }
    }
    
    return (0, undef);
}

# Find all cycles in graph (for directed graphs)
# Pass: ($graph_ref)
# Returns: \@cycles where each cycle is an arrayref of nodes
sub find_all_cycles {
    my ($graph) = @_;
    my @all_cycles;
    my %visited;
    my %rec_stack;
    
    sub _find_cycles_dfs {
        my ($node, $graph, $visited, $rec_stack, $path, $cycles) = @_;
        
        $visited->{$node} = 1;
        $rec_stack->{$node} = 1;
        push @$path, $node;
        
        foreach my $neighbor (get_neighbors($graph, $node)) {
            if (!$visited->{$neighbor}) {
                _find_cycles_dfs($neighbor, $graph, $visited, $rec_stack, $path, $cycles);
            } elsif ($rec_stack->{$neighbor}) {
                # Found a cycle
                my $idx = 0;
                $idx++ until $path->[$idx] eq $neighbor || $idx >= @$path;
                my @cycle = @$path[$idx .. $#$path];
                push @$cycles, \@cycle;
            }
        }
        
        $rec_stack->{$node} = 0;
        pop @$path;
    }
    
    foreach my $node (keys %{$graph->{nodes}}) {
        if (!$visited{$node}) {
            my @path;
            _find_cycles_dfs($node, $graph, \%visited, \%rec_stack, \@path, \@all_cycles);
        }
    }
    
    return \@all_cycles;
}

# ============================================================================
# BASIC PATHFINDING - BFS & DFS
# ============================================================================

# Breadth-First Search - finds shortest path (unweighted)
# Pass: ($graph_ref, $start, $goal)
# Returns: (\@path, $distance) or (undef, undef) if no path
sub bfs_shortest_path {
    my ($graph, $start, $goal) = @_;
    
    return ([$start], 0) if $start eq $goal;
    
    my @queue = ([$start, [$start]]);
    my %visited = ($start => 1);
    
    while (@queue) {
        my ($node, $path) = @{shift @queue};
        
        foreach my $neighbor (get_neighbors($graph, $node)) {
            next if $visited{$neighbor};
            
            my @new_path = (@$path, $neighbor);
            
            if ($neighbor eq $goal) {
                return (\@new_path, scalar(@new_path) - 1);
            }
            
            push @queue, [$neighbor, \@new_path];
            $visited{$neighbor} = 1;
        }
    }
    
    return (undef, undef);
}

# Depth-First Search - finds a path (not necessarily shortest)
# Pass: ($graph_ref, $start, $goal)
# Returns: \@path or undef
sub dfs_find_path {
    my ($graph, $start, $goal) = @_;
    my %visited;
    
    sub _dfs_path {
        my ($node, $goal, $graph, $visited, $path) = @_;
        
        return 1 if $node eq $goal;
        
        $visited->{$node} = 1;
        push @$path, $node;
        
        foreach my $neighbor (get_neighbors($graph, $node)) {
            next if $visited->{$neighbor};
            
            if (_dfs_path($neighbor, $goal, $graph, $visited, $path)) {
                return 1;
            }
        }
        
        pop @$path;
        return 0;
    }
    
    my @path = ();
    if (_dfs_path($start, $goal, $graph, \%visited, \@path)) {
        push @path, $goal;
        return \@path;
    }
    
    return undef;
}

# Find all paths between two nodes (use with caution on large graphs)
# Pass: ($graph_ref, $start, $goal, $max_paths)
# Returns: \@paths where each path is an arrayref
sub find_all_paths {
    my ($graph, $start, $goal, $max_paths) = @_;
    $max_paths //= 1000;  # Safety limit
    my @all_paths;
    
    sub _find_paths_dfs {
        my ($node, $goal, $graph, $visited, $path, $all_paths, $max) = @_;
        
        return if @$all_paths >= $max;
        
        if ($node eq $goal) {
            push @$all_paths, [@$path, $goal];
            return;
        }
        
        $visited->{$node} = 1;
        push @$path, $node;
        
        foreach my $neighbor (get_neighbors($graph, $node)) {
            next if $visited->{$neighbor};
            _find_paths_dfs($neighbor, $goal, $graph, $visited, $path, $all_paths, $max);
        }
        
        pop @$path;
        delete $visited->{$node};
    }
    
    my %visited;
    my @path;
    _find_paths_dfs($start, $goal, $graph, \%visited, \@path, \@all_paths, $max_paths);
    
    return \@all_paths;
}

# ============================================================================
# DIJKSTRA'S ALGORITHM - SHORTEST PATH (WEIGHTED)
# ============================================================================

# Dijkstra's algorithm for weighted graphs
# Pass: ($graph_ref, $start, $goal)
# Returns: (\@path, $total_cost) or (undef, undef)
sub dijkstra {
    my ($graph, $start, $goal) = @_;
    
    my %distances;
    my %previous;
    my %visited;
    
    # Initialize distances
    foreach my $node (keys %{$graph->{nodes}}) {
        $distances{$node} = 999999999;  # "Infinity"
    }
    $distances{$start} = 0;
    
    # Priority queue (simple array implementation)
    my @queue = ($start);
    
    while (@queue) {
        # Find node with minimum distance
        @queue = sort { $distances{$a} <=> $distances{$b} } @queue;
        my $current = shift @queue;
        
        last if $current eq $goal;
        next if $visited{$current};
        
        $visited{$current} = 1;
        
        foreach my $neighbor (get_neighbors($graph, $current)) {
            next if $visited{$neighbor};
            
            my $weight = get_edge_weight($graph, $current, $neighbor) // 1;
            my $alt_distance = $distances{$current} + $weight;
            
            if ($alt_distance < $distances{$neighbor}) {
                $distances{$neighbor} = $alt_distance;
                $previous{$neighbor} = $current;
                push @queue, $neighbor unless grep { $_ eq $neighbor } @queue;
            }
        }
    }
    
    # Reconstruct path
    return (undef, undef) unless exists $previous{$goal} || $start eq $goal;
    
    my @path;
    my $current = $goal;
    while ($current) {
        unshift @path, $current;
        $current = $previous{$current};
    }
    
    return (\@path, $distances{$goal});
}

# ============================================================================
# A* ALGORITHM - HEURISTIC PATHFINDING
# ============================================================================

# A* algorithm with heuristic function
# Pass: ($graph_ref, $start, $goal, $heuristic_sub)
# $heuristic_sub should be: sub { my ($node, $goal) = @_; return estimate; }
# Returns: (\@path, $total_cost) or (undef, undef)
sub astar {
    my ($graph, $start, $goal, $heuristic) = @_;
    
    # Default heuristic (0 = becomes Dijkstra)
    $heuristic //= sub { return 0; };
    
    my %g_score;  # Cost from start to node
    my %f_score;  # g_score + heuristic
    my %previous;
    my %visited;
    
    # Initialize
    foreach my $node (keys %{$graph->{nodes}}) {
        $g_score{$node} = 999999999;
        $f_score{$node} = 999999999;
    }
    $g_score{$start} = 0;
    $f_score{$start} = $heuristic->($start, $goal);
    
    my @open_set = ($start);
    
    while (@open_set) {
        # Find node with lowest f_score
        @open_set = sort { $f_score{$a} <=> $f_score{$b} } @open_set;
        my $current = shift @open_set;
        
        if ($current eq $goal) {
            # Reconstruct path
            my @path;
            while ($current) {
                unshift @path, $current;
                $current = $previous{$current};
            }
            return (\@path, $g_score{$goal});
        }
        
        $visited{$current} = 1;
        
        foreach my $neighbor (get_neighbors($graph, $current)) {
            next if $visited{$neighbor};
            
            my $weight = get_edge_weight($graph, $current, $neighbor) // 1;
            my $tentative_g = $g_score{$current} + $weight;
            
            if ($tentative_g < $g_score{$neighbor}) {
                $previous{$neighbor} = $current;
                $g_score{$neighbor} = $tentative_g;
                $f_score{$neighbor} = $tentative_g + $heuristic->($neighbor, $goal);
                
                push @open_set, $neighbor unless grep { $_ eq $neighbor } @open_set;
            }
        }
    }
    
    return (undef, undef);
}

# ============================================================================
# TOPOLOGICAL SORT & DAG OPERATIONS
# ============================================================================

# Topological sort using Kahn's algorithm
# Pass: ($graph_ref)
# Returns: \@sorted_nodes or undef if graph has cycles
sub topological_sort {
    my ($graph) = @_;
    
    # Calculate in-degrees
    my %in_degree;
    foreach my $node (keys %{$graph->{nodes}}) {
        $in_degree{$node} = 0;
    }
    
    foreach my $edge (keys %{$graph->{edges}}) {
        my ($from, $to) = split /,/, $edge;
        $in_degree{$to}++;
    }
    
    # Queue of nodes with no incoming edges
    my @queue = grep { $in_degree{$_} == 0 } keys %in_degree;
    my @sorted;
    
    while (@queue) {
        my $node = shift @queue;
        push @sorted, $node;
        
        foreach my $neighbor (get_neighbors($graph, $node)) {
            $in_degree{$neighbor}--;
            push @queue, $neighbor if $in_degree{$neighbor} == 0;
        }
    }
    
    # If not all nodes processed, graph has cycle
    return undef if @sorted != scalar(keys %{$graph->{nodes}});
    
    return \@sorted;
}

# Count all paths in DAG using dynamic programming
# Pass: ($graph_ref, $start, $goal)
# Returns: $count or undef if not a DAG
sub count_dag_paths {
    my ($graph, $start, $goal) = @_;
    
    # Check if DAG
    my ($has_cycle) = detect_cycle_dfs($graph);
    return undef if $has_cycle;
    
    my $topo = topological_sort($graph);
    return undef unless $topo;
    
    my %path_count;
    $path_count{$start} = 1;
    
    foreach my $node (@$topo) {
        next unless exists $path_count{$node};
        
        foreach my $neighbor (get_neighbors($graph, $node)) {
            $path_count{$neighbor} += $path_count{$node};
        }
    }
    
    return $path_count{$goal} // 0;
}

# ============================================================================
# GRID TO GRAPH CONVERSION
# ============================================================================

# Convert a 2D grid to a graph (for pathfinding on grids)
# Pass: ($grid_ref, $meta_ref, $walkable_chars, $diagonal)
# $walkable_chars = arrayref of characters that can be walked on
# Returns: $graph_ref with nodes as "row,col"
sub grid_to_graph {
    my ($grid, $meta, $walkable, $diagonal) = @_;
    $walkable //= ['.'];
    $diagonal //= 0;
    
    my %walkable_map = map { $_ => 1 } @$walkable;
    my $graph = new_graph(0);
    
    # Directions: 4-way or 8-way
    my @directions = ([-1, 0], [1, 0], [0, -1], [0, 1]);
    if ($diagonal) {
        push @directions, ([-1, -1], [-1, 1], [1, -1], [1, 1]);
    }
    
    for my $r ($meta->{min_row} // 0 .. $meta->{max_row}) {
        for my $c ($meta->{min_col} // 0 .. $meta->{max_col}) {
            my $cell = $grid->{"$r,$c"};
            next unless $walkable_map{$cell};
            
            my $node = "$r,$c";
            add_node($graph, $node);
            
            foreach my $dir (@directions) {
                my ($dr, $dc) = @$dir;
                my $nr = $r + $dr;
                my $nc = $c + $dc;
                my $neighbor_cell = $grid->{"$nr,$nc"};
                
                if ($neighbor_cell && $walkable_map{$neighbor_cell}) {
                    my $neighbor_node = "$nr,$nc";
                    add_edge($graph, $node, $neighbor_node, 1);
                }
            }
        }
    }
    
    return $graph;
}

# Manhattan distance heuristic for grid-based A*
# Pass: ($node1, $node2) where nodes are "row,col" strings
sub manhattan_distance {
    my ($n1, $n2) = @_;
    my ($r1, $c1) = split /,/, $n1;
    my ($r2, $c2) = split /,/, $n2;
    return abs($r1 - $r2) + abs($c1 - $c2);
}

# ============================================================================
# UTILITY FUNCTIONS
# ============================================================================

# Print graph structure
sub print_graph {
    my ($graph) = @_;
    
    print "Nodes: " . join(", ", sort keys %{$graph->{nodes}}) . "\n";
    print "Edges:\n";
    
    foreach my $node (sort keys %{$graph->{adjacency}}) {
        my @neighbors = @{$graph->{adjacency}{$node}};
        foreach my $neighbor (@neighbors) {
            my $weight = get_edge_weight($graph, $node, $neighbor);
            print "  $node -> $neighbor";
            print " (weight: $weight)" if $graph->{weighted};
            print "\n";
        }
    }
}

# Check if graph is connected (for undirected graphs)
sub is_connected {
    my ($graph) = @_;
    
    my @nodes = keys %{$graph->{nodes}};
    return 1 if @nodes == 0;
    
    my %visited;
    my @queue = ($nodes[0]);
    $visited{$nodes[0]} = 1;
    
    while (@queue) {
        my $node = shift @queue;
        foreach my $neighbor (get_neighbors($graph, $node)) {
            next if $visited{$neighbor};
            $visited{$neighbor} = 1;
            push @queue, $neighbor;
        }
    }
    
    return scalar(keys %visited) == scalar(@nodes);
}



=comment
# ============================================================================
# EXAMPLE USAGE
# ============================================================================

print "=== Example 1: Basic Pathfinding ===\n";
my $g1 = new_graph(0);
add_edge($g1, 'A', 'B');
add_edge($g1, 'A', 'C');
add_edge($g1, 'B', 'D');
add_edge($g1, 'C', 'D');
add_edge($g1, 'D', 'E');

my ($path, $dist) = bfs_shortest_path($g1, 'A', 'E');
print "BFS Path from A to E: " . join(" -> ", @$path) . " (distance: $dist)\n";

print "\n=== Example 2: Weighted Graph (Dijkstra) ===\n";
my $g2 = new_graph(1);
add_edge($g2, 'A', 'B', 4);
add_edge($g2, 'A', 'C', 2);
add_edge($g2, 'B', 'D', 3);
add_edge($g2, 'C', 'D', 1);
add_edge($g2, 'C', 'E', 5);
add_edge($g2, 'D', 'E', 2);

my ($dpath, $dcost) = dijkstra($g2, 'A', 'E');
print "Dijkstra Path from A to E: " . join(" -> ", @$dpath) . " (cost: $dcost)\n";

print "\n=== Example 3: Cycle Detection ===\n";
my $g3 = new_graph(0);
add_edge($g3, 'A', 'B');
add_edge($g3, 'B', 'C');
add_edge($g3, 'C', 'A');  # Creates cycle

my ($has_cycle, $cycle) = detect_cycle_dfs($g3);
if ($has_cycle) {
    print "Cycle detected: " . join(" -> ", @$cycle) . "\n";
}

print "\n=== Example 4: A* with Manhattan Distance ===\n";
# Create a simple grid graph
my $g4 = new_graph(1);
for my $r (0..2) {
    for my $c (0..2) {
        my $node = "$r,$c";
        add_node($g4, $node);
        add_edge($g4, $node, ($r+1).",$c", 1) if $r < 2;
        add_edge($g4, $node, "$r,".($c+1), 1) if $c < 2;
    }
}

my $heuristic = sub {
    my ($node, $goal) = @_;
    return manhattan_distance($node, $goal);
};

my ($apath, $acost) = astar($g4, "0,0", "2,2", $heuristic);
print "A* Path from (0,0) to (2,2): " . join(" -> ", @$apath) . " (cost: $acost)\n";

print "\n=== Example 5: DAG Path Counting ===\n";
my $g5 = new_graph(0);
add_edge($g5, 'A', 'B');
add_edge($g5, 'A', 'C');
add_edge($g5, 'B', 'D');
add_edge($g5, 'C', 'D');

my $count = count_dag_paths($g5, 'A', 'D');
print "Number of paths from A to D in DAG: $count\n";
=cut

1;  # Important: return true value at end of library file
