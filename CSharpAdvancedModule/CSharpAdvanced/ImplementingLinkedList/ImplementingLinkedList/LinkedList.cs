﻿using System;
using System.Collections.Generic;
using System.Text;

namespace ImplementingLinkedList
{
    public class LinkedList
    {
        public Node Head { get; set; }
        public Node Tail { get; set; }

        public void ForEach(Action<Node> action)
        {
            Node currentNode = Head;
            while (currentNode!=null)
            {
                action(currentNode);
                currentNode = currentNode.Next;
            }
        }
        public void AddHead(Node node)
        {
            if (Head == null)
            {
                Head = node;
                Tail = node;
            }
            else
            {
                node.Next = Head;
                Head.Previous = node;
                Head = node;
            }
            
        }

        public void PrintList()
        {
            this.ForEach(node => Console.WriteLine(node.Value));
        }
        public Node[] ToArray()
        {
            List<Node> list = new List<Node>();
            this.ForEach(node => list.Add(node));

            return list.ToArray();
        }

        public void ReverseList()
        {
            Node currentNode = Tail;
            while (currentNode != null)
            {
                Console.WriteLine(currentNode.Value);
                currentNode = currentNode.Previous;
            }
        }
        public void AddLast (Node newTail)
        {
            if (Tail == null)
            {
                Tail = newTail;
                Head = newTail;
            }
            else
            {
                newTail.Previous = Tail;
                Tail.Next = newTail;
                Tail = newTail;
            }
        }
        public Node RemoveFirst()
        {
            var oldHead = this.Head;
            this.Head = this.Head.Next;
            Head.Previous = null;
            return oldHead;
        }
        public Node RemoveLast()
        {
            var oldTail = this.Tail;
            Tail = this.Tail.Previous;
            Tail.Next = null;
            return oldTail;
        }
        public bool RemoveItem(int value)
        {
            Node currentNode = Head;

            while (currentNode != null)
            {
                if (currentNode.Value == value)
                {
                    currentNode.Previous.Next = currentNode.Next;
                    currentNode.Next.Previous = currentNode.Previous;
                    return true;
                }
                currentNode = currentNode.Next;
            }
            return false;
        }
        public bool Contains(int value)
        {
            bool isFound = false;
            ForEach(node =>
            {
                if (node.Value == value) isFound = true;
            });
            
            return isFound;
        }
    }
   
}
