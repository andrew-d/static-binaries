class CycleException(ValueError):
    pass


def topological_sort(edge_list):
    # edge_set is consumed, need a copy
    edge_set = set([tuple(i) for i in edge_list])

    # node_list will contain the ordered nodes
    node_list = list()

    # source_set is the set of nodes with no incoming edges
    node_from_list, node_to_list = zip(*edge_set)
    source_set = set(node_from_list) - set(node_to_list)

    while len(source_set) != 0:
        # Pop node_from off source_set and insert it in node_list
        node_from = source_set.pop()
        node_list.append(node_from)

        # Find nodes which have a common edge with node_from
        from_selection = [e for e in edge_set if e[0] == node_from]
        for edge in from_selection:
            # Remove the edge from the graph
            node_to = edge[1]
            edge_set.discard(edge)

            # If node_to doesn't have any remaining incoming edges...
            to_selection = [e for e in edge_set if e[1] == node_to]
            if len(to_selection) == 0:
                # ... add node_to to source_set
                source_set.add(node_to)

    if len(edge_set) != 0:
        raise CycleException(edge_set)

    return node_list
